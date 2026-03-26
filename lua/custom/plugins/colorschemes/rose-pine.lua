return {
  'rose-pine/neovim',
  name = 'rose-pine',
  priority = 1000, -- load before everything else
  config = function()
    require('rose-pine').setup {
      variant = 'main', -- 'main' (dark), 'moon' (softer dark), 'dawn' (light)
      -- styles = {
      --   transparency = true, -- Primeagen's signature transparent bg
      -- },
    }
    vim.cmd 'colorscheme rose-pine'
  end,
}
