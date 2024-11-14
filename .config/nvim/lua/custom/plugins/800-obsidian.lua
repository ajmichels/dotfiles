-- Plugin providing functionality similar to Obsidian
--
-- See https://github.com/epwalsh/obsidian.nvim
return {
  'epwalsh/obsidian.nvim',
  version = 'v3.9.0', -- recommended, use latest release instead of latest commit
  lazy = true,
  ft = 'markdown',
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  -- event = {
  --   -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
  --   -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
  --   "BufReadPre path/to/my-vault/**.md",
  --   "BufNewFile path/to/my-vault/**.md",
  -- },
  dependencies = {
    'nvim-lua/plenary.nvim',
    'hrsh7th/nvim-cmp', -- optional
    'nvim-telescope/telescope.nvim', -- optional
    'nvim-treesitter', -- optional
  },
  keys = {
    { '<leader>os', '<cmd>ObsidianSearch<cr>', desc = '[O]bsidian [S]earch' },
    { '<leader>oq', '<cmd>ObsidianQuickSwitch<cr>', desc = '[O]bsidian [Q]uick Switch' },
    { '<leader>on', ':ObsidianNew', desc = '[O]bsidian [N]ew Note' },
    { '<leader>ob', '<cmd>ObsidianBacklinks<cr>', desc = '[O]bsidian [B]acklinks' },
    { '<leader>ot', '<cmd>ObsidianTags<cr>', desc = '[O]bsidian [T]ags' },
    { '<leader>od', '<cmd>ObsidianDailies<cr>', desc = '[O]bsidian [D]ailies' },
    { '<leader>ol', ':ObsidianLink', mode = { 'v' }, desc = '[O]bsidian [L]ink' },
    { '<leader>or', ':ObsidianRename', desc = '[O]bsidian [R]ename' },
    { '<leader>oo', '<cmd>ObsidianOpen<cr>', desc = '[O]bsidian [O]pen' },
    { '<leader>op', ':ObsidianPasteImg', desc = '[O]bsidian [P]aste Image' },
    { '<leader>oW', '<cmd>ObsidianWorkspace<cr>', desc = '[O]bsidian [W]orkspace' },
    { '<leader>oT', '<cmd>ObsidianTemplate<cr>', desc = '[O]bsidian [T]emplate' },
    {
      '<leader>ow',
      function()
        local year = vim.fn.system [[date +'%Y-W' | tr -d '\n']]
        local week = tonumber(vim.fn.system [[date +'%U' | tr -d '\n']]) + 1
        vim.cmd(':ObsidianNew' .. year .. week)
      end,
      desc = '[O]bsidian [W]eekly Note',
    },
  },
  opts = {
    disable_frontmatter = false,

    -- Optional, completion of wiki links, local markdown links, and tags using nvim-cmp.
    completion = {
      -- Set to false to disable completion.
      nvim_cmp = true,
      -- Trigger completion at 2 chars.
      min_chars = 2,
    },

    -- Optional, customize how note IDs are generated given an optional title.
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ''
      if title ~= nil then
        return title
        -- If title is given, transform it into valid file name.
        -- suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return tostring(os.time()) .. '-' .. suffix
    end,

    -- Optional, by default when you use `:ObsidianFollowLink` on a link to an external
    -- URL it will be ignored but you can customize this behavior here.
    ---@param url string
    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      vim.fn.jobstart { 'open', url } -- Mac OS
      -- vim.fn.jobstart({"xdg-open", url})  -- linux
    end,

    picker = {
      -- Set your preferred picker. Can be one of 'telescope.nvim', 'fzf-lua', or 'mini.pick'.
      name = 'telescope.nvim',
      -- Optional, configure key mappings for the picker. These are the defaults.
      -- Not all pickers support all mappings.
      mappings = {
        -- Create a new note from your query.
        new = '<C-x>',
        -- Insert a link to the selected note.
        insert_link = '<C-l>',
      },
    },
  },
  config = function(_, opts)
    local localConfig = require 'local.obsidian'

    for k, v in pairs(localConfig) do
      opts[k] = v
    end

    require('obsidian').setup(opts)
  end,
}
