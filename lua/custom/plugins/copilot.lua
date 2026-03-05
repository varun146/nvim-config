return {
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        -- Disable ghost text since blink.cmp will handle suggestions
        suggestion = { enabled = false },
        panel = { enabled = false },
        filetypes = {
          ['*'] = true, -- enable for all filetypes by default
        },
      }

      vim.keymap.set('n', '<leader>tc', function()
        require('copilot.command').toggle()
        local status = require('copilot.client').is_disabled() and 'disabled' or 'enabled'
        vim.notify('Copilot ' .. status, vim.log.levels.INFO)
      end, { desc = '[T]oggle [C]opilot' })
    end,
  },

  {
    'giuxtaposition/blink-cmp-copilot',
    dependencies = { 'zbirenbaum/copilot.lua' },
  },
}
