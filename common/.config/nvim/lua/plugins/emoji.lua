return {
  "allaman/emoji.nvim",
  lazy = true,
  ft = { "markdown", "text", "plaintex", "gitcommit", "scratch" },
  dependencies = {
    -- util for handling paths
    "nvim-lua/plenary.nvim",
    -- optional for telescope integration
    "nvim-telescope/telescope.nvim",
    -- optional for fzf-lua integration via vim.ui.select
    -- 'ibhagwan/fzf-lua',
    -- optional for blink.cmp integration
    "saghen/blink.cmp",
  },
  opts = {
    -- default is false, also needed for blink.cmp integration!
    enable_cmp_integration = true,
  },
  config = function(_, opts)
    require("emoji").setup(opts)
    -- optional for telescope integration
    local ts = require("telescope").load_extension("emoji")
    vim.keymap.set("n", "<leader>se", ts.emoji, { desc = "[S]earch [E]moji" })
  end,
}
