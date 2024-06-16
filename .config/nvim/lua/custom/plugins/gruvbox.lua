return { -- Gruvbox Colorscheme
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  config = true,
  opts = {
    overrides = {
      SignColumn = { bg = '#282828' },
      TabLineFill = { bg = '#282828', fg = '#a89984' },
    },
  },
  init = function()
    vim.cmd.colorscheme 'gruvbox'
  end,
}
