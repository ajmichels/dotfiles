return {
  'willothy/nvim-cokeline',
  version = 'v0.4.0',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required for v0.4.0+
    'nvim-tree/nvim-web-devicons', -- If you want devicons
    'stevearc/resession.nvim', -- Optional, for persistent history
  },
  opts = {
    buffers = {
      new_buffers_position = 'number', -- order buffers by their number
      delete_on_right_click = false,
    },
    components = {
      {
        text = function(buffer)
          return ' ' .. buffer.devicon.icon .. ' '
        end,
      },
      {
        text = function(buffer)
          return buffer.number .. ': '
        end,
      },
      {
        text = function(buffer)
          return buffer.unique_prefix
        end,
      },
      {
        text = function(buffer)
          return buffer.filename .. ' '
        end,
        italics = function(buffer)
          return buffer.is_focused
        end,
      },
    },
  },
}
