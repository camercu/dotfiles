return {
  "epwalsh/obsidian.nvim",
  ft = "markdown",
  opts = {
    -- No hardcoded vault: walk up from whatever markdown buffer is open to find
    -- the nearest `.obsidian/` folder, so this follows any vault you're editing.
    -- Falls back to the buffer's own directory if none is found (same as
    -- obsidian.nvim's own default for a loose markdown file outside a vault).
    workspaces = {
      {
        path = function()
          local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
          local vault = vim.fs.find(".obsidian", { path = dir, upward = true, type = "directory" })[1]
          return vault and vim.fs.dirname(vault) or dir
        end,
      },
    },
    ui = { enable = false }, -- render-markdown.nvim already renders the buffer
  },
}
