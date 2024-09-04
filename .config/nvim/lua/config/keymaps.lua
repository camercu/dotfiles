-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Miscellaneous
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode easily' })
vim.keymap.set('n', '<leader><Enter>', 'm`O<Esc>``', { desc = 'Insert newline above current' })
vim.keymap.set('n', '<C-w>n', '<cmd>enew<cr>', { desc = 'New file in current window' })
vim.keymap.set('n', '<leader>cL', '<cmd>LspRestart<cr>', { desc = 'Restart LSP' })
vim.keymap.set('n', '<leader>cx', '<cmd>LazyExtras<cr>', { desc = 'LazyExtras' })
