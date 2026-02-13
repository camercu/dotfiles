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

--
-- Text manipulation
--
-- Title case entire line
-- built referenceing :help ordinary-atom
vim.keymap.set("n", "gat", "m`guu<cmd>s/\\<\\a/\\u&/g<cr><cmd>noh<cr>``", { desc = "Title Case Line" })
-- Sentence case entire line (capitalize first letter, rest lowercase)
vim.keymap.set("n", "gaT", "m`guu<cmd>s/\\<\\a/\\u&/<cr><cmd>noh<cr>``", { desc = "Sentence case line" })
