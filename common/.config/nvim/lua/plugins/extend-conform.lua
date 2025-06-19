return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      -- java = { 'google-java-format' },
      markdown = { "prettier" },
      nix = { "alejandra" },
      python = { "isort", "ruff" },
      rust = { "rustfmt" },
    })
  end,
}
