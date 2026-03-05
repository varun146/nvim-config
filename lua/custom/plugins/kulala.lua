return {
  'mistweaverco/kulala.nvim',
  ft = 'http',
  opts = {
    default_env = 'dev',
    debug = false,
    display_mode = 'split', -- opens response in a split pane
    split_direction = 'vertical',
  },
  keys = {
    {
      '<leader>rr',
      function()
        require('kulala').run()
      end,
      desc = 'REST: Run Request',
      ft = 'http',
    },
    {
      '<leader>ra',
      function()
        require('kulala').run_all()
      end,
      desc = 'REST: Run All',
      ft = 'http',
    },
    {
      '<leader>rp',
      function()
        require('kulala').jump_prev()
      end,
      desc = 'REST: Prev Request',
      ft = 'http',
    },
    {
      '<leader>rn',
      function()
        require('kulala').jump_next()
      end,
      desc = 'REST: Next Request',
      ft = 'http',
    },
  },
}
