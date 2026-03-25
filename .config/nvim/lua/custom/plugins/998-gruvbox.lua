-- Plugin to provide GruvBox theme colors
--
-- See https://github.com/ellisonleao/gruvbox.nvim
return {
  {
    -- Gruvbox Colorscheme
    'ellisonleao/gruvbox.nvim',
    version = '2.0.0',
    priority = 1000,
    config = true,
    opts = {
      palette_overrides = {},
      overrides = {
        TabLineFill = { bg = '#282828', fg = '#EBDBB2' },
        ErrorMsg = { bg = 'none', fg = '#E15E4E' },
      },
    },
    init = function()
      vim.cmd.colorscheme 'gruvbox'
    end,
  },
}
