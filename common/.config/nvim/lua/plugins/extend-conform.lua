return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
      -- java = { 'google-java-format' },
      markdown = { "prettier" },
      nix = { "alejandra" },
      python = {
        "ruff_fix", -- Fix auto-fixable lint errors
        "ruff_format", -- Run the Ruff formatter
        "ruff_organize_imports", -- Organize imports
      },
      rust = { "rustfmt" },
    })
  end,
}
