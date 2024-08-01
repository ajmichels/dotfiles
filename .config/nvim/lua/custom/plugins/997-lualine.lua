return {
  'nvim-lualine/lualine.nvim',
  -- version = '', The author of this plugin doesn't seem to release tagged versions
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  opts = {
    theme = 'gruvbox_dark',
  },
  config = function()
    -- local custom_gruvbox = require'lualine.themes.gruvbox'
    local colors = {
      black = '#282828',
      white = '#ebdbb2',
      red = '#e15e4e',
      green = '#a8aa37',
      blue = '#87a197',
      yellow = '#df8337',
      gray = '#a89984',
      darkgray = '#3c3836',
      lightgray = '#504945',
      inactivegray = '#7c6f64',
    }

    local custom_gruvbox = {
      normal = {
        a = { bg = colors.gray, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.darkgray, fg = colors.gray },
      },
      insert = {
        a = { bg = colors.blue, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.lightgray, fg = colors.white },
      },
      visual = {
        a = { bg = colors.yellow, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.inactivegray, fg = colors.black },
      },
      replace = {
        a = { bg = colors.red, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.black, fg = colors.white },
      },
      command = {
        a = { bg = colors.green, fg = colors.black, gui = 'bold' },
        b = { bg = colors.lightgray, fg = colors.white },
        c = { bg = colors.inactivegray, fg = colors.black },
      },
      inactive = {
        a = { bg = colors.darkgray, fg = colors.gray, gui = 'bold' },
        b = { bg = colors.darkgray, fg = colors.gray },
        c = { bg = colors.darkgray, fg = colors.gray },
      },
    }

    require('lualine').setup {
      options = { theme = custom_gruvbox },
    }
  end,
}
