return {
  {
    "hrsh7th/nvim-cmp",
    opts = function(_, opts)
      local cmp = require("cmp")
      opts.mapping = vim.tbl_extend("force", opts.mapping, {
        ["<C-y>"] = cmp.mapping.confirm({ select = true }),
        ["<CR>"] = function(fallback)
          cmp.abort()
          fallback()
        end,
      })
    end,
  },
}
