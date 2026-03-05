return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'rcasia/neotest-java',
  },
  ft = 'java',
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-java' {
          -- change to 'gradle' if you use Gradle
          runner = 'maven',
          -- optionally point to your root pom.xml if needed
        },
      },
    }

    -- Keymaps
    vim.keymap.set('n', '<leader>tn', function()
      require('neotest').run.run()
    end, { desc = 'Test: Run Nearest' })
    vim.keymap.set('n', '<leader>tf', function()
      require('neotest').run.run(vim.fn.expand '%')
    end, { desc = 'Test: Run File' })
    vim.keymap.set('n', '<leader>ts', function()
      require('neotest').run.run { suite = true }
    end, { desc = 'Test: Run Suite' })
    vim.keymap.set('n', '<leader>to', function()
      require('neotest').output_panel.toggle()
    end, { desc = 'Test: Toggle Output Panel' })
    vim.keymap.set('n', '<leader>tp', function()
      require('neotest').output.open { enter = true }
    end, { desc = 'Test: Open Output' })
    vim.keymap.set('n', '<leader>tS', function()
      require('neotest').summary.toggle()
    end, { desc = 'Test: Toggle Summary' })
  end,
}
