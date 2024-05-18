return {
  'levouh/tint.nvim',
  config = function()
    require('tint').setup {
      tint_background_colors = true, -- Tint background portions of highlight groups
    }
  end,
}
