return {
  dir = vim.fn.stdpath 'config',
  name = 'record-meeting',
  lazy = false,
  config = function()
    require('custom.record-meeting').setup()
  end,
}
