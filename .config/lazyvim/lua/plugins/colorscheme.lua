return {
  -- add and configure desired theme
  {
    "catppuccin/nvim",
    priority = 1000, -- load early
  },

  -- Configure LazyVim to load theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-frappe",
    },
  },
}

-- return {
--   -- add gruvbox
--   { "ellisonleao/gruvbox.nvim" },
--
--   -- Configure LazyVim to load gruvbox
--   {
--     "LazyVim/LazyVim",
--     opts = {
--       colorscheme = "gruvbox",
--     },
--   },
-- }
