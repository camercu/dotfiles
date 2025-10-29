return {
  "mason-org/mason.nvim",
  opts = function(_, opts)
    vim.list_extend(opts.ensure_installed, {
      -- add tools here
      "biome",
      "gofumpt",
      "goimports",
      "gopls",
      "hadolint",
      "isort",
      "marksman",
      "pyright",
      "ruff",
      "shellcheck",
      "trivy",
    })
  end,
}
