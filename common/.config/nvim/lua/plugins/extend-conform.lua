return {
  'stevearc/conform.nvim',
  opts = {
    formatters_by_ft = {
      markdown = { 'prettier' },
      python = { 'isort', 'ruff' },
      nix = { 'alejandra' },
    },
  },
}
