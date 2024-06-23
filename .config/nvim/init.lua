--[[

Helpful info about Neovim and related tech
  - https://learnxinyminutes.com/docs/lua/
  - :help lua-guide
  - (or HTML version): https://neovim.io/doc/user/lua-guide.html
  - :Tutor
  - keymap "<space>sh" to [s]earch the [h]elp documentation,
  - If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

--]]

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.g.have_nerd_font = true

-- [[ Setting options ]]
-- See `:help vim.opt`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

vim.opt.spelllang = 'en_us' -- set spelling language
vim.opt.number = true -- Make line numbers default
-- vim.opt.relativenumber = true -- relative line numbers
vim.opt.showmode = false -- Don't show the mode, since it's already in the status line
-- vim.opt.clipboard = 'unnamedplus' -- Sync clipboard between OS and Neovim. See `:help clipboard`
vim.opt.breakindent = true -- Enable break indent
vim.opt.undofile = true -- Save undo history (even when exiting vim)
vim.opt.ignorecase = true -- Case-insensitive searching
vim.opt.smartcase = true -- UNLESS \C or one or more capital letters in the search term
vim.opt.signcolumn = 'yes' -- Keep signcolumn (gutter on the left) on by default
vim.opt.updatetime = 250 -- Decrease update time
vim.opt.timeoutlen = 300 -- Decrease mapped sequence wait time (i.e. Displays which-key popup sooner)
vim.opt.splitright = true -- new vsplits created to the right of current window
vim.opt.splitbelow = true -- new hsplits created below current window
vim.opt.list = true -- display whitespace characters. see `:help 'list'`
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' } -- whitespace characters to show and how. See `:help listchars`
vim.opt.inccommand = 'split' -- Preview substitutions live, as you type!
vim.opt.cursorline = true -- Show which line your cursor is on
vim.opt.scrolloff = 10 -- Minimal number of screen lines to keep above and below the cursor.
vim.opt.colorcolumn = '100' -- create a ruler on column 100

-- add filetype patterns for OpenAPI and Swagger
vim.filetype.add {
  pattern = {
    ['openapi.*%.ya?ml'] = 'yaml.openapi',
    ['openapi.*%.json'] = 'json.openapi',
    ['swagger.*%.ya?ml'] = 'yaml.openapi',
    ['swagger.*%.json'] = 'json.openapi',
  },
}

vim.opt.tabstop = 4 -- number of spaces a tab character will render as
vim.opt.softtabstop = 0
vim.o.expandtab = true -- use spaces when pressing the tab key
vim.opt.shiftwidth = 4

-- [[ Basic Keymaps ]] See `:help vim.keymap.set()`

vim.opt.hlsearch = true -- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>') -- hide search highlight by hitting <Esc>

vim.o.wrap = false -- do not wrap long lines
vim.o.incsearch = true -- show search results as typing

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Break out into normal mode while using built in terminal
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Disable arrow keys in normal mode
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', ';', ':', { desc = 'Use ; for :', remap = false })

-- [[ Basic Autocommands ]e
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- [[ Install `lazy.nvim` plugin manager ]]
--    See `:help lazy.nvim.txt` or https://github.com/folke/lazy.nvim for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

-- [[ Configure and install plugins ]]
-- Install, update, and remove plugins, run `:Lazy`
require('lazy').setup({
  'tpope/vim-sleuth', -- Detect tabstop and shiftwidth automatically
  'christoomey/vim-tmux-navigator', -- making moving from vim in tmux to another pane easier

  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  -- require 'kickstart.plugins.debug',
  -- require 'kickstart.plugins.lint',
  -- require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps

  -- See `:help lazy.nvim-lazy.nvim-structuring-your-plugins`
  { import = 'custom.plugins' }, -- load plugins from `lua/custom/plugins/*.lua`
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
