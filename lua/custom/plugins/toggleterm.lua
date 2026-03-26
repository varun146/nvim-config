return {
  'akinsho/toggleterm.nvim',
  version = '*',
  opts = {
    size = 15,
    open_mapping = [[<C-\>]],
    direction = 'horizontal', -- or 'vertical', 'float', 'tab'
    shade_terminals = true,
    persist_size = true,
    close_on_exit = false,
  },
  keys = {
    { '<C-\\>', desc = 'Toggle Terminal' },
    {
      '<leader>mr',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local file = vim.fn.expand '%:p' -- full path to current file
        local classname = vim.fn.expand '%:t:r' -- filename without extension
        local dir = vim.fn.expand '%:p:h' -- directory of the file

        local run = Terminal:new {
          cmd = 'cd ' .. dir .. ' && javac ' .. file .. ' && java ' .. classname,
          direction = 'horizontal',

          close_on_exit = false,
          on_open = function(term)
            vim.api.nvim_buf_set_keymap(term.bufnr, 'n', 'q', '<cmd>close<CR>', { noremap = true, silent = true })
          end,
        }
        run:toggle()
      end,
      desc = 'Java: Compile and Run current file',
    },
    {
      '<leader>mv',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local mvn = Terminal:new { cmd = 'mvn validate', hidden = true, direction = 'horizontal', close_on_exit = false }
        mvn:toggle()
      end,
      desc = 'Maven: Verify',
    },
    {
      '<leader>mt',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local mvn = Terminal:new { cmd = 'mvn test', hidden = true, direction = 'horizontal', close_on_exit = false }
        mvn:toggle()
      end,
      desc = 'Maven: Test',
    },
    {
      '<leader>mc',
      function()
        local Terminal = require('toggleterm.terminal').Terminal
        local mvn = Terminal:new { cmd = 'mvn clean install', hidden = true, direction = 'horizontal', close_on_exit = false }
        mvn:toggle()
      end,
      desc = 'Maven: Clean Install',
    },
  },
}
