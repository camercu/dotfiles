return {
  "allaman/emoji.nvim",
  lazy = true,
  ft = { "markdown", "text", "plaintex", "gitcommit", "scratch" },
  dependencies = {
    -- util for handling paths
    "nvim-lua/plenary.nvim",
    -- optional for blink.cmp integration
    "saghen/blink.cmp",
  },
  opts = {
    -- default is false, also needed for blink.cmp integration!
    enable_cmp_integration = true,
  },
  config = function(_, opts)
    require("emoji").setup(opts)
    -- vim.ui.select is backed by the snacks picker (fuzzy search included),
    -- so no telescope dependency needed just for this one command.
    vim.keymap.set("n", "<leader>se", function()
      vim.ui.select(require("emoji.data").emoji_items(), {
        prompt = "Emoji",
        format_item = function(item)
          return item.label
        end,
      }, function(item)
        if item then require("emoji.utils").insert_string_at_current_cursor(item.character) end
      end)
    end, { desc = "[S]earch [E]moji" })
  end,
}
