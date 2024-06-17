return { -- Gruvbox Colorscheme
  'ellisonleao/gruvbox.nvim',
  priority = 1000,
  config = true,
  opts = {
    palette_overrides = {
      red = '#e15e4e',
      green = '#a8aa37',
      yellow = '#dbb14e',
      blue = '#87a197',
      purple = '#c693a1',
      aqua = '#93b587',
      orange = '#df8337',
      neutral_red = '#b63833',
      neutral_green = '#87872b',
      neutral_yellow = '#be913a',
      neutral_blue = '#4f7c7e',
      neutral_purple = '#a37087',
      neutral_aqua = '#729374',
      neutral_orange = '#bc6228',
      dark_red = '#613638',
      dark_green = '#5e6344',
      dark_aqua = '#484f3c',
      gray = '#928374',
    },
    overrides = {
      SignColumn = { bg = '#282828' },
      TabLineFill = { bg = '#282828', fg = '#a89984' },
    },
  },
  init = function()
    vim.cmd.colorscheme 'gruvbox'
  end,
}
