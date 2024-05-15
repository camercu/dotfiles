return {
  'fedepujol/move.nvim',
  opts = {},
  config = function()
    require('move').setup {}

    -- Normal-mode commands
    vim.keymap.set('n', '<A-j>', ':MoveLine(1)<CR>', { noremap = true, silent = true, desc = 'Move line down' })
    vim.keymap.set('n', '<A-k>', ':MoveLine(-1)<CR>', { noremap = true, silent = true, desc = 'Move line up' })

    -- Visual-mode commands
    vim.keymap.set('v', '<A-j>', ':MoveBlock(1)<CR>', { noremap = true, silent = true, desc = 'Move block down' })
    vim.keymap.set('v', '<A-k>', ':MoveBlock(-1)<CR>', { noremap = true, silent = true, desc = 'Move block up' })
  end,
}
