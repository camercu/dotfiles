return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      -- add tools here
      "gofumpt",
      "goimports",
      "gopls",
      "hadolint",
      "isort",
      "marksman",
      "ruff",
      "shellcheck",
    })
  end,
}
