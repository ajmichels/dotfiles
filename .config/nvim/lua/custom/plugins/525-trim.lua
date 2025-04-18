-- Highlight and trim trailing whitespace in buffers
--
-- See https://github.com/cappyzawa/trim.nvim
return {
  'cappyzawa/trim.nvim',
  version = 'v0.10.2',
  opts = {
    highlight = true,
  },
  ft = {
    'javascript',
    'html',
    'less',
    'sass',
    'css',
    'lua',
    'php',
  },
}
