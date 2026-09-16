-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

--
-- Editor
--
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode easily" })
vim.keymap.set("n", "<C-w>n", "<cmd>enew<cr>", { desc = "New file in current window" })
vim.keymap.set("n", "<leader>w", "<cmd>write<cr>", { desc = "Save/write file" })
vim.keymap.set("n", "<leader>cL", "<cmd>LspRestart<cr>", { desc = "Restart LSP" })
vim.keymap.set("n", "<leader>cx", "<cmd>LazyExtras<cr>", { desc = "LazyExtras" })
-- Intentionally overrides Snacks default picker mapping; see plugins/extend-snacks-picker.lua.
vim.keymap.set("n", "<leader><leader>", "<cmd>e #<cr>", { desc = "Switch to other buffer" })

-- inserting blank lines
vim.keymap.set("n", "<leader><Enter>", "m`O<Esc>``", { desc = "Insert newline above current" })
vim.keymap.set("n", "<leader><S-Enter>", "m`o<Esc>``", { desc = "Insert newline below current" })

-- Keep search matches in center
vim.keymap.set("n", "n", "nzzzv", { desc = "Next Search Result" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev Search Result" })

-- Title Case / Sentence case moved to plugins/textcase.lua as coerce.nvim
-- cases (`gat`/`gaT`), so they get which-key labels and word/motion/visual
-- scope like every other coerce case instead of a whole-line-only special case.
