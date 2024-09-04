return {
  'nvim-treesitter/nvim-treesitter',
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      -- add parsers here
      'arduino',
      'csv',
      'dockerfile',
      'editorconfig',
      'git_config',
      'gitignore',
      'go',
      'gomod',
      'gosum',
      'gotmpl',
      'gowork',
      'ini',
      'java',
      'just',
      'latex',
      'make',
      'rust',
      'ssh_config',
      'tmux',
    })
  end,
}
