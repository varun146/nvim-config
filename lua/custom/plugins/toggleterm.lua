return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    size = 15,
    open_mapping = [[<C-\>]],
    direction = 'horizontal', -- or 'vertical', 'float', 'tab'
    shade_terminals = true,
    persist_size = true,
    close_on_exit = true,
  },
  keys = {
    { '<C-\\>', desc = 'Toggle Terminal' },
    {
      '<leader>mv',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local mvn = Terminal:new { cmd = 'mvn validate', hidden = true, direction = 'horizontal' }
        mvn:toggle()
      end,
      desc = 'Maven: Verify',
    },
    {
      '<leader>mt',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local mvn = Terminal:new { cmd = 'mvn test', hidden = true, direction = 'horizontal' }
        mvn:toggle()
      end,
      desc = 'Maven: Test',
    },
    {
      '<leader>mc',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local mvn = Terminal:new { cmd = 'mvn clean install', hidden = true, direction = 'horizontal' }
        mvn:toggle()
      end,
      desc = 'Maven: Clean Install',
    },
  },
}
