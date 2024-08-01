return { -- Highlight todo, notes, etc in comments
  'folke/todo-comments.nvim',
  version = 'v1.2.0',
  event = 'VimEnter',
  dependencies = { 'nvim-lua/plenary.nvim' },
  opts = { signs = false },
}
