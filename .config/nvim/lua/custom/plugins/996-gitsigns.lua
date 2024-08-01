-- Here is a more advanced example where we pass configuration
-- options to `gitsigns.nvim`. This is equivalent to the following Lua:
--    require('gitsigns').setup({ ... })
--
-- See `:help gitsigns` to understand what the configuration keys do

return { -- Adds git related signs to the gutter, as well as utilities for managing changes
  'lewis6991/gitsigns.nvim',
  version = 'v0.9.0',
  opts = {
    signs = {
      add = { text = '' }, -- '+'
      change = { text = '' }, -- '~'
      delete = { text = '󰆴' }, -- '_'
      topdelete = { text = '‾' },
      changedelete = { text = '' }, -- '~'
    },
  },
}
