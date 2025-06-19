return {
  "nvim-neo-tree/neo-tree.nvim",

  init = function()
    vim.g.neotree = {
      auto_close = true,
      auto_open = false,
      auto_update = true,
      update_to_buf_dir = false,
    }
  end,

  opts = {
    close_if_last_window = true,
    hijack_netrw_behavior = "disabled",

    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
    },
  },
}
