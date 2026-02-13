return {
  "Canop/nvim-bacon",
  config = function()
    require("bacon").setup({
      quickfix = {
        enabled = true, -- Enable Quickfix integration
        event_trigger = true, -- Trigger QuickFixCmdPost after populating Quickfix list
      },
    })
    local map = LazyVim.safe_keymap_set
    map("n", "<leader>cn", ":BaconLoad<CR>:w<CR>:BaconNext<CR>", { desc = "Navigate to next bacon location" })
    map("n", "<leader>cb", ":BaconList<CR>", { desc = "Open bacon locations list" })
  end,
}
