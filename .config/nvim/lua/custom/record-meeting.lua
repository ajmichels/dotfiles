--[[

record-meeting.lua

Records a meeting, transcribes it, and appends AI-formatted notes into the
buffer you were editing when you started recording -- all without leaving
NeoVim, and without needing any custom shell scripts on disk.

FLOW
====

  <leader>ms (:RecordMeetingStart)
    -> spawns `ffmpeg` as a background job, recording the mic straight to
       ~/Recordings/<name>-<timestamp>.<wav|m4a>
    -> remembers which buffer was active, so notes land back in the right
       place even if you switch buffers while waiting
    -> starts a `caffeinate -i -w <ffmpeg-pid>` job to block idle system
       sleep for as long as ffmpeg runs (releases itself automatically when
       ffmpeg exits)
    -> starts an hourly "still recording" reminder and a 3-hour auto-stop,
       in case you forget to stop it
    -> writes this Neovim instance's RPC address to a file, purely so an
       external process (see SLEEP HOOK below) can find it

  <leader>me (:RecordMeetingStop), the 3-hour cap, or the sleep hook firing
    -> stops the ffmpeg job (SIGTERM; ffmpeg finalizes the file cleanly)
    -> clears the reminder/cap timers and the RPC address file
    -> runs `macparakeet-cli transcribe` on the recording (speaker diarization
       on, plain text output) into a scratch temp directory
    -> pipes the resulting transcript into `claude -p` (see FORMAT_PROMPT)
       to fix up speaker-label mistakes and produce short meeting notes
    -> appends the notes to the end of the buffer that was active at
       recording start, and also copies them to the system clipboard as a
       fallback if that buffer got closed in the meantime
    -> deletes the scratch temp directory

DEPENDENCIES
============

Only three external CLI tools are ever invoked: `ffmpeg` (recording),
`macparakeet-cli` (local speech-to-text + diarization), and `claude`
(speaker-label cleanup / note formatting). No wrapper shell scripts are
involved -- everything above is orchestrated directly via `vim.fn.jobstart`.

SLEEP HANDLING
==============

Display sleep alone doesn't affect a background recording. System sleep
does: CoreAudio tears down the input device, and if ffmpeg is killed after
that happens, the output file can come out corrupted (this is why the
default format is wav, not m4a/aac -- see FORMATS below).

`caffeinate -i` (started in M.start) prevents *idle* system sleep, which
covers "no keyboard/mouse activity for the whole meeting". It cannot
prevent a forced sleep from closing the laptop lid.

For lid-close specifically, this module exposes an optional integration
point: on start, it writes its own `v:servername` (the RPC socket address
any Neovim instance can be remote-controlled through) to
~/.cache/record-meeting-nvim-addr. If the optional `sleepwatcher` tool
(https://formulae.brew.sh/formula/sleepwatcher) is installed and a
`~/.sleep` script is set up to read that file and run:

  nvim --server "$(cat ~/.cache/record-meeting-nvim-addr)" \
    --remote-send ':RecordMeetingStop<CR>'

...then a lid-close triggers a normal, clean :RecordMeetingStop *before* the
system fully suspends (IOKit gives processes a short grace window before
sleeping). The rest of the pipeline (transcribe/format/append) does not
need to finish before sleep completes -- if the Mac actually suspends
mid-transcription, that background job just pauses and resumes with
everything else on wake, since it's plain batch processing with no live
audio device involved.

This is entirely optional. Nothing in M.start/M.stop depends on
~/.cache/record-meeting-nvim-addr being read by anything -- if sleepwatcher
isn't installed, that file is simply never consumed, and normal manual
start/stop still works exactly as described above.

COMMANDS / KEYMAPS
==================

  :RecordMeetingStart [name]     <leader>ms   start recording
  :RecordMeetingStop             <leader>me   stop, transcribe, append notes
  :RecordMeetingReprocess <path>              re-run transcribe+format+append
                                               on an existing recording file
                                               (e.g. after a pipeline failure)
  :RecordMeetingFormat [fmt]                  get/set format (wav|m4a), no
                                               arg reports the current format

Only one recording can be active at a time (tracked via `state.job_id`).

--]]

local M = {}

-- Everything about the single in-flight recording, if any. `bufnr` is
-- captured at start time so notes always land back where recording began,
-- even if focus moves to another buffer while transcription is running.
local state = {
  job_id = nil, -- ffmpeg's jobstart id
  outfile = nil, -- path ffmpeg is writing to
  bufnr = nil, -- buffer to append notes into once done
  caffeinate_id = nil, -- jobstart id of the paired `caffeinate -w` process
  reminder_timer = nil, -- repeating "still recording" uv timer
  cap_timer = nil, -- one-shot auto-stop uv timer
  start_time = nil, -- os.time() when recording began, for the reminder message
}

local REMINDER_INTERVAL_MS = 60 * 60 * 1000 -- nudge every hour
local MAX_DURATION_MS = 3 * 60 * 60 * 1000 -- auto-stop after 3 hours

-- wav has no trailing index to lose, so an abrupt cutoff (e.g. a sleep-hook
-- race tearing down the audio device mid-write) still leaves a readable
-- file. m4a/aac is smaller but can end up fully undecodable if killed before
-- it finalizes its moov atom. Default to wav; switch with :RecordMeetingFormat.
local FORMATS = {
  wav = { ext = 'wav', args = { '-c:a', 'pcm_s16le' } },
  m4a = { ext = 'm4a', args = { '-c:a', 'aac', '-b:a', '128k' } },
}

-- User-configurable settings; overridden via M.setup({ format = ... }).
local config = {
  format = 'wav',
}

-- Optional hook point: if something external (e.g. a sleepwatcher `~/.sleep`
-- script) wants to trigger a stop before system sleep, it can read this file
-- for the current Neovim RPC address and `--remote-send ':RecordMeetingStop<CR>'`.
-- Nothing in this module depends on that file being read by anything.
local ADDR_FILE = vim.fn.expand '~/.cache/record-meeting-nvim-addr'

-- Stops and closes both safety-net timers. Called on every stop path
-- (manual, sleep-hook, or the cap timer stopping itself) so a finished
-- recording never leaves a stray timer armed.
local function clear_timers()
  if state.reminder_timer then
    state.reminder_timer:stop()
    state.reminder_timer:close()
    state.reminder_timer = nil
  end
  if state.cap_timer then
    state.cap_timer:stop()
    state.cap_timer:close()
    state.cap_timer = nil
  end
end

-- Instructions given to `claude -p` along with the raw transcript on stdin.
-- macparakeet-cli's diarization sometimes splits one speaker into two labels
-- or merges two speakers into one; this prompt asks claude to reconcile
-- that from context, without ever inventing real names it can't know.
local FORMAT_PROMPT = [[
You are formatting a raw speaker-labeled meeting transcript into concise meeting notes for an Obsidian vault.

Rules:
- The transcript's speaker labels (Speaker 1, Speaker 2, ...) may be wrong: the diarization model
  sometimes splits one speaker into two labels, or merges two speakers into one. Re-read the
  dialogue and merge/split labels where the content makes it obvious (consistent phrasing,
  self-references, replies to a question the same person just asked).
- You do not know real names. Keep corrected labels as "Speaker 1", "Speaker 2", etc. Do not guess
  real names.
- Output ONLY markdown in this exact structure, nothing else, no preamble, no code fences:

```markdown
## Claude Meetings Summary

### Topics Heading

- concise bullets covering what was discussed, decisions made, and action items
  * sub-bullets when appropriate
```
]]

-- Writes the final notes to the system clipboard (always, as a fallback)
-- and appends them to the end of bufnr (the buffer active when recording
-- started), if that buffer still exists.
local function append_notes(bufnr, lines)
  vim.fn.setreg('+', table.concat(lines, '\n'))

  if not vim.api.nvim_buf_is_valid(bufnr) then
    vim.notify('Target buffer no longer open; notes are on the clipboard', vim.log.levels.WARN)
    return
  end
  local lastline = vim.api.nvim_buf_line_count(bufnr)
  vim.api.nvim_buf_set_lines(bufnr, lastline, lastline, false, { '' })
  vim.api.nvim_buf_set_lines(bufnr, lastline + 1, lastline + 1, false, lines)
  vim.notify 'Meeting notes appended'
end

-- Last stage of the pipeline: runs `claude -p` with FORMAT_PROMPT as the
-- prompt and the raw transcript fed in over stdin (via chansend/chanclose,
-- the same thing `cat transcript.txt | claude -p '...'` would do on a
-- terminal). stdout is buffered so on_stdout fires once with the complete
-- response, which then gets appended to bufnr. workdir (macparakeet-cli's
-- scratch output directory) is removed once this finishes either way.
local function format_with_claude(transcript_path, workdir, bufnr)
  vim.notify 'Formatting notes with claude ...'

  local transcript = vim.fn.readfile(transcript_path)
  local claude_job

  claude_job = vim.fn.jobstart({ 'claude', '-p', FORMAT_PROMPT }, {
    stdout_buffered = true,
    on_stdout = function(_, data)
      if not data then
        return
      end
      local lines = {}
      for _, line in ipairs(data) do
        if line ~= '' then
          table.insert(lines, line)
        end
      end
      if #lines == 0 then
        return
      end
      vim.schedule(function()
        append_notes(bufnr, lines)
      end)
    end,
    on_exit = function(_, code)
      if code ~= 0 then
        vim.schedule(function()
          vim.notify('claude formatting failed (exit ' .. code .. ')', vim.log.levels.ERROR)
        end)
      end
      vim.fn.delete(workdir, 'rf')
    end,
  })

  if claude_job <= 0 then
    vim.notify('Failed to start claude', vim.log.levels.ERROR)
    vim.fn.delete(workdir, 'rf')
    return
  end

  vim.fn.chansend(claude_job, transcript)
  vim.fn.chanclose(claude_job, 'stdin')
end

-- First stage of the post-recording pipeline: runs macparakeet-cli against
-- the finished recording (outfile), with speaker detection on and plain
-- text output, into a fresh scratch directory. Once it exits, the single
-- output file it wrote is handed off to format_with_claude. Cleans up
-- workdir itself on any failure path (format_with_claude owns cleanup on
-- the success path, since it needs the transcript file to still exist).
local function transcribe(outfile, bufnr)
  local workdir = vim.fn.tempname()
  vim.fn.mkdir(workdir, 'p')

  vim.notify('Transcribing ' .. outfile .. ' ...')

  local job_id = vim.fn.jobstart({
    'macparakeet-cli',
    'transcribe',
    '--speaker-detection=on',
    '-f',
    'text',
    '--output-dir',
    workdir,
    outfile,
  }, {
    on_exit = function(_, code)
      vim.schedule(function()
        if code ~= 0 then
          vim.notify('macparakeet-cli failed (exit ' .. code .. ')', vim.log.levels.ERROR)
          vim.fn.delete(workdir, 'rf')
          return
        end

        local files = vim.fn.glob(workdir .. '/*', false, true)
        if #files == 0 then
          vim.notify('Transcription produced no output file', vim.log.levels.ERROR)
          vim.fn.delete(workdir, 'rf')
          return
        end

        format_with_claude(files[1], workdir, bufnr)
      end)
    end,
  })

  if job_id <= 0 then
    vim.notify('Failed to start macparakeet-cli', vim.log.levels.ERROR)
    vim.fn.delete(workdir, 'rf')
  end
end

-- Reprocesses an already-recorded file that never made it through
-- transcribe/format (e.g. a crash or a manual stop before the pipeline
-- could run). Takes the same path through transcribe() -> format_with_claude()
-- as a normal M.stop(), just without touching any recording state -- there's
-- no ffmpeg job, timers, or caffeinate/servername bookkeeping to unwind.
-- Notes land in whatever buffer is current when this is invoked.
function M.reprocess(path)
  if not path or path == '' then
    vim.notify('Usage: :RecordMeetingReprocess <path-to-recording>', vim.log.levels.ERROR)
    return
  end

  local outfile = vim.fn.expand(path)
  if vim.fn.filereadable(outfile) == 0 then
    vim.notify('File not found: ' .. outfile, vim.log.levels.ERROR)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()

  vim.notify('Reprocessing ' .. outfile .. ' ...')

  transcribe(outfile, bufnr)
end

-- Starts recording. Refuses to start a second recording on top of one
-- already in progress (only one `state.job_id` is tracked at a time).
-- name is an optional prefix for the output filename (default "meeting");
-- the actual file is <name>-<timestamp>.<format>.
function M.start(name)
  if state.job_id then
    vim.notify('Recording already in progress: ' .. state.outfile, vim.log.levels.WARN)
    return
  end

  name = (name and name ~= '') and name or 'meeting'
  local fmt = FORMATS[config.format] or FORMATS.wav
  local outdir = vim.fn.expand '~/Recordings'
  vim.fn.mkdir(outdir, 'p')
  local outfile = string.format('%s/%s-%s.%s', outdir, name, os.date '%Y-%m-%d-%H%M%S', fmt.ext)

  -- Capture the buffer now: this is where notes will be appended later,
  -- regardless of whatever buffer happens to be focused when they're ready.
  state.bufnr = vim.api.nvim_get_current_buf()
  state.outfile = outfile

  -- Device ":1" is the MacBook's built-in mic (see `ffmpeg -f avfoundation
  -- -list_devices true -i ""` to confirm the index on a given machine).
  local cmd = { 'ffmpeg', '-y', '-f', 'avfoundation', '-i', ':1' }
  vim.list_extend(cmd, fmt.args)
  table.insert(cmd, outfile)

  state.job_id = vim.fn.jobstart(cmd, {
    on_exit = function(_, code)
      -- 0 = clean exit, 255 = terminated by signal (the normal case for a
      -- deliberate stop via jobstop's SIGTERM). Anything else is a real
      -- failure worth surfacing.
      if code ~= 0 and code ~= 255 then
        vim.schedule(function()
          vim.notify('ffmpeg exited unexpectedly (code ' .. code .. ')', vim.log.levels.ERROR)
        end)
      end
    end,
  })

  if state.job_id <= 0 then
    vim.notify('Failed to start ffmpeg recording', vim.log.levels.ERROR)
    state.job_id = nil
    return
  end

  state.start_time = os.time()

  -- Make sure this Neovim instance has an RPC address, and publish it so an
  -- external sleep hook (if any) knows where to send :RecordMeetingStop.
  -- This is a no-op from our own perspective if nothing ever reads the file.
  local addr = vim.v.servername
  if not addr or addr == '' then
    addr = vim.fn.serverstart()
  end
  vim.fn.mkdir(vim.fn.fnamemodify(ADDR_FILE, ':h'), 'p')
  pcall(vim.fn.writefile, { addr }, ADDR_FILE)

  -- Block idle system sleep for as long as ffmpeg is running; releases
  -- itself automatically once the ffmpeg process exits.
  local pid = vim.fn.jobpid(state.job_id)
  state.caffeinate_id = vim.fn.jobstart { 'caffeinate', '-i', '-w', tostring(pid) }

  -- Safety net #1: a periodic nudge in case the recording is left running
  -- far longer than any real meeting would go.
  state.reminder_timer = vim.loop.new_timer()
  state.reminder_timer:start(
    REMINDER_INTERVAL_MS,
    REMINDER_INTERVAL_MS,
    vim.schedule_wrap(function()
      local minutes = math.floor(os.difftime(os.time(), state.start_time) / 60)
      vim.notify('Still recording (' .. minutes .. ' min) -- <leader>me to stop', vim.log.levels.WARN)
    end)
  )

  -- Safety net #2: a hard ceiling so a truly forgotten recording can't run
  -- indefinitely (e.g. overnight). Calls the normal M.stop(), so this goes
  -- through the exact same transcribe/format/append pipeline as a manual stop.
  state.cap_timer = vim.loop.new_timer()
  state.cap_timer:start(
    MAX_DURATION_MS,
    0,
    vim.schedule_wrap(function()
      vim.notify('Auto-stopping recording after 3 hours (safety cap)', vim.log.levels.WARN)
      M.stop()
    end)
  )

  vim.notify('Recording started -> ' .. outfile)
end

-- Stops the current recording (if any) and kicks off transcription. Called
-- directly by <leader>me / :RecordMeetingStop, by the 3-hour cap timer, or
-- remotely via `nvim --server ... --remote-send ':RecordMeetingStop<CR>'`
-- from the optional sleepwatcher hook.
function M.stop()
  if not state.job_id then
    vim.notify('No recording in progress', vim.log.levels.WARN)
    return
  end

  local outfile = state.outfile
  local bufnr = state.bufnr

  clear_timers()

  -- SIGTERM: ffmpeg finalizes and closes the output file cleanly rather
  -- than being abruptly killed.
  vim.fn.jobstop(state.job_id)
  state.job_id = nil
  state.outfile = nil
  state.bufnr = nil
  state.caffeinate_id = nil
  state.start_time = nil

  pcall(vim.fn.delete, ADDR_FILE)

  vim.notify('Stopped recording. Transcribing ' .. outfile .. ' ...')

  transcribe(outfile, bufnr)
end

-- Registers commands/keymaps and applies user config. Called once from
-- lua/custom/plugins/900-record-meeting.lua on startup.
function M.setup(opts)
  opts = opts or {}
  if opts.format then
    if not FORMATS[opts.format] then
      vim.notify('Unknown recording format: ' .. tostring(opts.format) .. ' (falling back to wav)', vim.log.levels.WARN)
    else
      config.format = opts.format
    end
  end

  vim.api.nvim_create_user_command('RecordMeetingStart', function(cmd_opts)
    M.start(cmd_opts.args)
  end, { nargs = '?', desc = 'Start recording a meeting' })

  vim.api.nvim_create_user_command('RecordMeetingStop', function()
    M.stop()
  end, { desc = 'Stop recording and append transcribed notes' })

  vim.api.nvim_create_user_command('RecordMeetingReprocess', function(cmd_opts)
    M.reprocess(cmd_opts.args)
  end, {
    nargs = 1,
    complete = 'file',
    desc = 'Reprocess an existing recording (transcribe + format + append)',
  })

  -- With no argument, reports the current format; otherwise switches it for
  -- the next recording (does not affect one already in progress).
  vim.api.nvim_create_user_command('RecordMeetingFormat', function(cmd_opts)
    local fmt = cmd_opts.args
    if fmt == '' then
      vim.notify('Current recording format: ' .. config.format)
      return
    end
    if not FORMATS[fmt] then
      vim.notify('Unknown format "' .. fmt .. '" (valid: wav, m4a)', vim.log.levels.ERROR)
      return
    end
    config.format = fmt
    vim.notify('Recording format set to ' .. fmt)
  end, {
    nargs = '?',
    complete = function()
      return vim.tbl_keys(FORMATS)
    end,
    desc = 'Get/set the recording format (wav, m4a)',
  })

  vim.keymap.set('n', '<leader>ms', '<cmd>RecordMeetingStart<CR>', { desc = '[M]eeting [S]tart recording' })
  vim.keymap.set('n', '<leader>me', '<cmd>RecordMeetingStop<CR>', { desc = '[M]eeting [E]nd recording & transcribe' })
end

return M
