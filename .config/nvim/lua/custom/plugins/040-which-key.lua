-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end
--
-- https://github.com/folke/which-key.nvim

return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  version = 'v3.13.3',
  event = 'VimEnter',
  opts = {
    delay = 500,
    win = {
      no_overlap = false,
    },
    spec = {
      { '<leader>c', group = '[C]ode' },
      { '<leader>d', group = '[D]ocument' },
      { '<leader>r', group = '[R]ename' },
      { '<leader>s', group = '[S]earch' },
      { '<leader>w', group = '[W]orkspace' },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>o', group = '[O]bsidian' },
      { '<leader>g', group = '[G]it' },
    },
  },
}
