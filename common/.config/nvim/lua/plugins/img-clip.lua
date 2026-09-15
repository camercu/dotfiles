return {
  "HakonHarnes/img-clip.nvim",
  event = "VeryLazy",
  init = function()
    local ok, wk = pcall(require, "which-key")
    if ok then
      wk.add({ "<leader>i", group = "images" })
    end
  end,
  keys = {
    { "<leader>ip", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
    {
      "<leader>if",
      function()
        -- Snacks' file preview renders actual images (via snacks.image), unlike
        -- telescope's default previewer, so picking here doubles as an image browser.
        Snacks.picker.files({
          confirm = function(picker, item)
            picker:close()
            local filepath = item and Snacks.picker.util.path(item)
            if not filepath then
              vim.notify("No file path found in selected picker entry", vim.log.levels.WARN)
              return
            end
            require("img-clip").paste_image(nil, filepath)
          end,
        })
      end,
      desc = "Select image file to embed",
    },
  },
  opts = {
    default = {
      dir_path = "assets",
      use_absolute_path = false,
      drag_and_drop = {
        enabled = true,
        insert_mode = true,
      },
    },
    -- filetype specific options
    filetypes = {
      markdown = {
        download_images = true,
        template = vim.g.neovim_mode == "skitty" and "![i](./$FILE_PATH)" or "![$CURSOR](./$FILE_PATH)",
      },
      codecompanion = {
        prompt_for_file_name = false,
        template = "[Image]($FILE_PATH)",
        use_absolute_path = true,
      },
    },
  },
}
