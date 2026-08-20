--[[

mnotes.lua

Telescope pickers backed by the `mnotes` CLI (github.com/aj-michels/moneta-notes), the
FTS5/sqlite-vec index over the Obsidian vault. Two pickers:

  MnotesSearch (<leader>ns)     -- live search-as-you-type against `mnotes search`,
                                   defaulting to hybrid (fulltext + semantic) ranking.
  MnotesSearchFulltext (<leader>nf) -- same picker, fulltext-only. Useful fallback when
                                   the indexing daemon (required for hybrid/semantic) is down.
  MnotesTasks (<leader>nt)      -- notes tagged #task that are NOT also tagged #done.

Both pickers shell out to `mnotes` (never touching the SQLite index or vault directly) so
behavior always matches the CLI/MCP surface -- see moneta-notes' CLAUDE.md for why that
separation matters.

SEARCH DEBOUNCE
================

`mnotes search --mode=hybrid` embeds the query via a round-trip to the indexing daemon, so
re-running it on every keystroke would be janky. Input is debounced (150ms after typing
stops) and each search runs async via vim.system -- the picker's results update in place
whenever a response lands, without blocking the UI while waiting.

--]]

local pickers = require 'telescope.pickers'
local finders = require 'telescope.finders'
local conf = require('telescope.config').values
local actions = require 'telescope.actions'
local action_state = require 'telescope.actions.state'
local sorters = require 'telescope.sorters'

local M = {}

local DEBOUNCE_MS = 150
local SEARCH_LIMIT = 40

local function vault_path()
  return require('local.obsidian').workspaces[1].path
end

local function note_file_path(title)
  return vault_path() .. '/' .. title .. '.md'
end

local function open_note(entry)
  vim.cmd.edit { args = { note_file_path(entry.value) } }
end

local function entry_maker(item)
  local path = note_file_path(item.note_title)
  return {
    value = item.note_title,
    display = item.note_title,
    ordinal = item.note_title,
    path = path,
    filename = path,
    lnum = item.chunk_line_start,
  }
end

-- Runs `mnotes <args> --json` async, decodes the JSON array, and calls
-- cb(results, err) on the main loop.
local function run_mnotes(args, cb)
  local cmd = { 'mnotes' }
  vim.list_extend(cmd, args)
  table.insert(cmd, '--json')

  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        cb({}, vim.trim(result.stderr or 'mnotes exited with code ' .. result.code))
        return
      end
      local ok, decoded = pcall(vim.json.decode, result.stdout)
      if ok then
        cb(decoded, nil)
      else
        cb({}, 'failed to parse mnotes JSON output')
      end
    end)
  end)
end

function M.search(opts)
  opts = opts or {}
  local mode = opts.mode or 'hybrid'

  local picker
  local debounce_timer
  -- `picker:refresh()` (called from set_results below) re-triggers on_input_filter_cb
  -- with the *same* prompt text -- without this guard that loop never stops, and every
  -- tick resets the selected row back to the top (looks like scrolling "doesn't work").
  local last_query

  local function set_results(results)
    picker:refresh(finders.new_table { results = results, entry_maker = entry_maker }, { reset_prompt = false })
  end

  local function run_search(prompt)
    if prompt == '' then
      set_results {}
      return
    end
    run_mnotes({ 'search', prompt, '--mode=' .. mode, '--limit=' .. SEARCH_LIMIT }, function(results, err)
      if err then
        vim.notify('mnotes search: ' .. err, vim.log.levels.ERROR)
        return
      end
      set_results(results)
    end)
  end

  picker = pickers.new(opts, {
    prompt_title = 'Mnotes Search (' .. mode .. ')',
    finder = finders.new_table { results = {}, entry_maker = entry_maker },
    -- mnotes already returns results ranked (BM25/RRF) -- don't let telescope re-sort/filter.
    sorter = sorters.empty(),
    previewer = conf.grep_previewer(opts),
    on_input_filter_cb = function(query_text)
      if query_text == last_query then
        return query_text
      end
      last_query = query_text

      if debounce_timer then
        debounce_timer:stop()
      end
      debounce_timer = vim.defer_fn(function()
        run_search(query_text)
      end, DEBOUNCE_MS)
      return query_text
    end,
    attach_mappings = function(prompt_bufnr)
      actions.select_default:replace(function()
        local entry = action_state.get_selected_entry()
        actions.close(prompt_bufnr)
        if entry then
          open_note(entry)
        end
      end)
      return true
    end,
  })

  picker:find()
end

function M.open_tasks()
  run_mnotes({ 'tags', 'notes', 'task' }, function(task_notes, err)
    if err then
      vim.notify('mnotes tags notes task: ' .. err, vim.log.levels.ERROR)
      return
    end

    run_mnotes({ 'tags', 'notes', 'done' }, function(done_notes, done_err)
      if done_err then
        vim.notify('mnotes tags notes done: ' .. done_err, vim.log.levels.ERROR)
        return
      end

      local done = {}
      for _, note in ipairs(done_notes) do
        done[note.note_title] = true
      end

      local open_notes = {}
      for _, note in ipairs(task_notes) do
        if not done[note.note_title] then
          table.insert(open_notes, note)
        end
      end

      pickers
        .new({}, {
          prompt_title = 'Open Tasks (#task, not #done)',
          finder = finders.new_table { results = open_notes, entry_maker = entry_maker },
          sorter = conf.generic_sorter {},
          previewer = conf.grep_previewer {},
          attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
              local entry = action_state.get_selected_entry()
              actions.close(prompt_bufnr)
              if entry then
                open_note(entry)
              end
            end)
            return true
          end,
        })
        :find()
    end)
  end)
end

function M.setup()
  vim.api.nvim_create_user_command('MnotesSearch', function()
    M.search { mode = 'hybrid' }
  end, { desc = 'Telescope search over notes via mnotes (hybrid ranking)' })

  vim.api.nvim_create_user_command('MnotesSearchFulltext', function()
    M.search { mode = 'fulltext' }
  end, { desc = 'Telescope search over notes via mnotes (fulltext only, no daemon needed)' })

  vim.api.nvim_create_user_command('MnotesTasks', M.open_tasks, { desc = 'Telescope list of open #task notes (not #done)' })

  vim.keymap.set('n', '<leader>ns', '<cmd>MnotesSearch<CR>', { desc = '[N]otes [S]earch (mnotes)' })
  vim.keymap.set('n', '<leader>nf', '<cmd>MnotesSearchFulltext<CR>', { desc = '[N]otes [F]ulltext search (mnotes)' })
  vim.keymap.set('n', '<leader>nt', '<cmd>MnotesTasks<CR>', { desc = '[N]otes open [T]asks (mnotes)' })
end

return M
