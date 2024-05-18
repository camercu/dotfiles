-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- tab switching (in addition to defaults)
vim.keymap.set("n", "<leader><tab>n", "<cmd>tabnext<cr>", { desc = "[T]ab [N]ext" })
vim.keymap.set("n", "<leader><tab>p", "<cmd>tabnext<cr>", { desc = "[T]ab [P]revious" })

-- find with telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "[F]ind [H]elp" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "[F]ind [K]eymaps" })
vim.keymap.set("n", "<leader>fs", builtin.builtin, { desc = "[F]ind [S]elect Telescope" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "[F]ind current [W]ord" })
vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "[F]ind [D]iagnostics" })

-- Slightly advanced example of overriding default behavior and theme
vim.keymap.set("n", "<leader>/", function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
    winblend = 10,
    previewer = false,
  }))
end, { desc = "[/] Fuzzily search in current buffer" })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set("n", "<leader>f/", function()
  builtin.live_grep({
    grep_open_files = true,
    prompt_title = "Live Grep in Open Files",
  })
end, { desc = "[F]ind [/] in Open Files" })

-- comments
vim.keymap.set("n", "", "gcc", { remap = true, desc = "Toggle line comment with C-/" })
vim.keymap.set("v", "", "gcgv", { remap = true, desc = "Toggle comment linewise (visual) with C-/" })

-- floating terminal
local lazyterm = function()
  LazyVim.terminal(nil, { cwd = LazyVim.root() })
end
vim.keymap.set("n", "`", lazyterm, { desc = "Terminal (Root Dir)" })

-- miscellaneous
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode easily" })
-- vim.keymap.set("n", "<leader>w", "<cmd>w<cr>", { desc = "Save this file" })
vim.keymap.set("n", "<leader><Enter>", "m`O<Esc>``", { desc = "Insert newline above current line" })
