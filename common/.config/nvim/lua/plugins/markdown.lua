return {
  'tadmccorkle/markdown.nvim',
  ft = 'markdown',
  opts = {
    mappings = {
      inline_surround_toggle = 'gs', -- (string|boolean) toggle inline style
      inline_surround_toggle_line = 'gss', -- (string|boolean) line-wise toggle inline style
      inline_surround_delete = 'ds', -- (string|boolean) delete emphasis surrounding cursor
      inline_surround_change = 'cs', -- (string|boolean) change emphasis surrounding cursor
      link_add = 'gl', -- (string|boolean) add link
      link_follow = false, -- (string|boolean) follow link
      go_curr_heading = ']K', -- (string|boolean) set cursor to current section heading
      go_parent_heading = ']p', -- (string|boolean) set cursor to parent section heading
      go_next_heading = ']k', -- (string|boolean) set cursor to next section heading
      go_prev_heading = '[k', -- (string|boolean) set cursor to previous section heading
    },
    on_attach = function(bufnr)
      local map = function(mode, input, output, desc)
        local opts = { buffer = bufnr, desc = desc }
        vim.keymap.set(mode, input, output, opts)
      end
      local function toggle(key)
        return "<Esc>gv<Cmd>lua require'markdown.inline'" .. ".toggle_emphasis_visual'" .. key .. "'<CR>"
      end

      -- Toggle tasks
      map('n', '<M-c>', '<Cmd>MDTaskToggle<CR>', 'Toggle Task')
      map('x', '<M-c>', ':MDTaskToggle<CR>', 'Toggle Task')

      -- <C-b> and <C-i> toggle bold and italic
      map('x', '<C-b>', toggle('b'), 'Bold text')
      map('x', '<C-i>', toggle('i'), 'Italicize text')
      map('i', '<C-b>', '****<Esc>hi', 'Bold text')
      map('i', '<C-i>', '__<Esc>i', 'Italicize text')
    end,
  },
}
