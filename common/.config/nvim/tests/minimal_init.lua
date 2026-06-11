-- Minimal init for testing rust refactoring support.
-- Run from config root: make test
local data = vim.fn.stdpath "data"
local lazy = data .. "/lazy"

vim.cmd "set rtp+=." -- config root: queries/rust/*.scm
vim.opt.rtp:append(lazy .. "/refactoring.nvim")
vim.opt.rtp:append(lazy .. "/async.nvim")
vim.opt.rtp:append(lazy .. "/mini.nvim")
vim.opt.rtp:append(data .. "/site") -- treesitter parsers

require("mini.test").setup()

-- single source of truth: the LazyVim plugin spec
local spec = dofile "lua/plugins/extend-refactor.lua"
local opts = type(spec.opts) == "function" and spec.opts(spec, {}) or spec.opts or {}
if type(spec.config) == "function" then
  spec.config(spec, opts)
else
  require("refactoring").setup(opts)
end

vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_markers = { "Cargo.toml" },
  capabilities = {
    experimental = { serverStatusNotification = true },
  },
  handlers = {
    -- tests wait on this to know rust-analyzer finished indexing
    ["experimental/serverStatus"] = function(_, result)
      if result and result.quiescent then vim.g.ra_quiescent = true end
    end,
  },
})
vim.lsp.enable { "rust_analyzer" }

vim.g.mapleader = " "
vim.keymap.set("n", "<leader>av", function()
  return require("refactoring").extract_var()
end, { expr = true })
vim.keymap.set("n", "<leader>ai", function()
  return require("refactoring").inline_var()
end, { expr = true })
vim.keymap.set("n", "<leader>ae", function()
  return require("refactoring").extract_func()
end, { expr = true })
vim.keymap.set("n", "<leader>aI", function()
  return require("refactoring").inline_func()
end, { expr = true })

vim.keymap.set("n", "<leader>pv", function()
  return require("refactoring.debug").print_var { output_location = "below" }
end, { expr = true })
vim.keymap.set("n", "<leader>pp", function()
  return require("refactoring.debug").print_loc { output_location = "below" }
end, { expr = true })
vim.keymap.set("n", "<leader>pe", function()
  return require("refactoring.debug").print_exp { output_location = "below" }
end, { expr = true })
vim.keymap.set({ "x", "n" }, "<leader>pc", function()
  return require("refactoring.debug").cleanup()
end, { expr = true })
