---@module "neominimap.config.meta"
return {
  "Isrothy/neominimap.nvim",
  version = "v3.x.x",
  lazy = false, -- NOTE: NO NEED to Lazy load
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "lewis6991/gitsigns.nvim",
    "nvim-mini/mini.diff",
  },
  -- Optional. You can also set your own keybindings
  keys = {
    -- Global Minimap Controls
    { "<leader>umm", "<cmd>Neominimap Toggle<cr>", desc = "Toggle global minimap" },
    { "<leader>umo", "<cmd>Neominimap Enable<cr>", desc = "Enable global minimap" },
    { "<leader>umc", "<cmd>Neominimap Disable<cr>", desc = "Disable global minimap" },
    { "<leader>umr", "<cmd>Neominimap Refresh<cr>", desc = "Refresh global minimap" },

    -- Window-Specific Minimap Controls
    { "<leader>umwt", "<cmd>Neominimap WinToggle<cr>", desc = "Toggle minimap for current window" },
    { "<leader>umwr", "<cmd>Neominimap WinRefresh<cr>", desc = "Refresh minimap for current window" },
    { "<leader>umwo", "<cmd>Neominimap WinEnable<cr>", desc = "Enable minimap for current window" },
    { "<leader>umwc", "<cmd>Neominimap WinDisable<cr>", desc = "Disable minimap for current window" },

    -- Tab-Specific Minimap Controls
    { "<leader>umtt", "<cmd>Neominimap TabToggle<cr>", desc = "Toggle minimap for current tab" },
    { "<leader>umtr", "<cmd>Neominimap TabRefresh<cr>", desc = "Refresh minimap for current tab" },
    { "<leader>umto", "<cmd>Neominimap TabEnable<cr>", desc = "Enable minimap for current tab" },
    { "<leader>umtc", "<cmd>Neominimap TabDisable<cr>", desc = "Disable minimap for current tab" },

    -- Buffer-Specific Minimap Controls
    { "<leader>umbt", "<cmd>Neominimap BufToggle<cr>", desc = "Toggle minimap for current buffer" },
    { "<leader>umbr", "<cmd>Neominimap BufRefresh<cr>", desc = "Refresh minimap for current buffer" },
    { "<leader>umbo", "<cmd>Neominimap BufEnable<cr>", desc = "Enable minimap for current buffer" },
    { "<leader>umbc", "<cmd>Neominimap BufDisable<cr>", desc = "Disable minimap for current buffer" },

    ---Focus Controls
    { "<leader>umf", "<cmd>Neominimap Focus<cr>", desc = "Focus minimap" },
    { "<leader>umu", "<cmd>Neominimap Unfocus<cr>", desc = "Unfocus minimap" },
    { "<leader>ums", "<cmd>Neominimap ToggleFocus<cr>", desc = "Toggle minimap focus" },
  },
  init = function()
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ "<leader>um", group = "+minimap" })
      wk.add({ "<leader>umb", group = "+buffer minimap" })
      wk.add({ "<leader>umt", group = "+tab minimap" })
      wk.add({ "<leader>umw", group = "+tab minimap" })
    end
    -- The following options are recommended when layout == "float"
    vim.opt.wrap = false
    vim.opt.sidescrolloff = 36 -- Set a large value

    --- Put your configuration here
    ---@type Neominimap.UserConfig
    vim.g.neominimap = {
      auto_enable = true,
    }
  end,
}
