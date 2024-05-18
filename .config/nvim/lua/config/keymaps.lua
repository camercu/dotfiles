-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Miscellaneous
vim.keymap.set({ 'i', 'x', 'n', 's' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save File' })
vim.keymap.set('i', 'jj', '<Esc>', { desc = 'Exit insert mode easily' })
vim.keymap.set('n', '<leader>w', ':w<Enter>', { desc = 'Save this file' })
vim.keymap.set('n', '<leader><Enter>', 'm`O<Esc>``', { desc = 'Insert newline above current line' })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight on <ESC> in Normal mode' })
vim.keymap.set('n', '<leader>ol', '<cmd>Lazy<cr>', { desc = '[O]pen [L]azy Plugin' })
vim.keymap.set('n', '<leader>om', '<cmd>Mason<cr>', { desc = '[O]pen [M]ason Plugin' })
vim.keymap.set('n', '<leader>qq', '<cmd>qa<cr>', { desc = 'Quit All' })

-- Better visual indent
vim.keymap.set('v', '<', '<gv', { desc = 'De-indent and reselect visual region' })
vim.keymap.set('v', '>', '>gv', { desc = 'Indent and reselect visual region' })

-- Comments
vim.keymap.set('n', '', 'gcc', { remap = true, desc = 'Toggle line comment with C-/' })
vim.keymap.set('v', '', 'gcgv', { remap = true, desc = 'Toggle comment linewise (visual) with C-/' })

-- Move lines with Alt+[hjkl]
vim.keymap.set('n', '<A-j>', '<cmd>move .+1<cr>==', { desc = 'Move Line Down' })
vim.keymap.set('n', '<A-k>', '<cmd>move .-2<cr>==', { desc = 'Move Line Up' })
vim.keymap.set('i', '<A-j>', '<esc><cmd>move .+1<cr>==gi', { desc = 'Move Line Down' })
vim.keymap.set('i', '<A-k>', '<esc><cmd>move .-2<cr>==gi', { desc = 'Move Line Up' })
vim.keymap.set('v', '<A-j>', "<cmd>move '>+1<cr>gv=gv", { desc = 'Move Lines Down' })
vim.keymap.set('v', '<A-k>', "<cmd>move '<-2<cr>gv=gv", { desc = 'Move Lines Up' })

-- Sane 'n/N' navigation in search.
-- source: https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
vim.keymap.set('n', 'n', "'Nn'[v:searchforward].'zv'", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('x', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('o', 'n', "'Nn'[v:searchforward]", { expr = true, desc = 'Next Search Result' })
vim.keymap.set('n', 'N', "'nN'[v:searchforward].'zv'", { expr = true, desc = 'Prev Search Result' })
vim.keymap.set('x', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Previous Search Result' })
vim.keymap.set('o', 'N', "'nN'[v:searchforward]", { expr = true, desc = 'Previous Search Result' })

-- Add undo break-points
vim.keymap.set('i', ',', ',<c-g>u')
vim.keymap.set('i', '.', '.<c-g>u')
vim.keymap.set('i', ';', ';<c-g>u')

-- Quickfix
vim.keymap.set('n', '[q', vim.cmd.cprev, { desc = 'Previous [Q]uickfix' })
vim.keymap.set('n', ']q', vim.cmd.cnext, { desc = 'Next [Q]uickfix' })

-- Convert Current line to Title Case
-- source: https://github.com/mischavandenburg/dotfiles/blob/main/nvim/lua/config/keymaps.lua
vim.keymap.set(
  'n',
  '<leader>rlt',
  "<cmd>lua require('textcase').current_word('to_title_case')<CR>",
  { desc = '[R]eplace [L]ine [T]itle Case' }
)

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- TIP: Disable arrow keys in normal mode
-- vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
-- vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
-- vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
-- vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- [[ Diagnostics ]]
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Next [D]iagnostic message' })
vim.keymap.set('n', '[e', diagnostic_goto(false, 'ERROR'), { desc = 'Previous [E]rror' })
vim.keymap.set('n', '[w', diagnostic_goto(false, 'WARN'), { desc = 'Previous [W]arning' })
vim.keymap.set('n', ']e', diagnostic_goto(true, 'ERROR'), { desc = 'Next [E]rror' })
vim.keymap.set('n', ']w', diagnostic_goto(true, 'WARN'), { desc = 'Next [W]arning' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- [[ Windows ]]

-- Move to window using CTRL+<hjkl>
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Split windows
vim.keymap.set('n', '<leader>|', ':vsplit<CR>', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>-', ':split<CR>', { desc = 'Split window horizontally' })

-- Resize window using CTRL + arrow keys
vim.keymap.set('n', '<C-Up>', '<cmd>resize +2<cr>', { desc = 'Increase Window Height' })
vim.keymap.set('n', '<C-Down>', '<cmd>resize -2<cr>', { desc = 'Decrease Window Height' })
vim.keymap.set('n', '<C-Left>', '<cmd>vertical resize -2<cr>', { desc = 'Decrease Window Width' })
vim.keymap.set('n', '<C-Right>', '<cmd>vertical resize +2<cr>', { desc = 'Increase Window Width' })

-- [[ Buffers ]]
vim.keymap.set('n', '[b', '<cmd>bprevious<cr>', { desc = 'Previous [B]uffer' })
vim.keymap.set('n', ']b', '<cmd>bnext<cr>', { desc = 'Next [B]uffer' })
vim.keymap.set('n', '<leader>bb', '<cmd>e #<cr>', { desc = 'Switch to Other Buffer' })

-- [[ Tabs ]]
vim.keymap.set('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = '[Tab] [L]ast' })
vim.keymap.set('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = '[Tab] [F]irst ' })
vim.keymap.set('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = '[Tab] Next' })
vim.keymap.set('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = '[Tab] Previous' })
vim.keymap.set('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = '[Tab] New' })
vim.keymap.set('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = '[Tab] [D]elete/Close' })
