return {
  "HakonHarnes/img-clip.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
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
        local telescope = require("telescope.builtin")
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")

        telescope.find_files({
          attach_mappings = function(_, map)
            local function embed_image(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              local filepath = entry and (entry.path or entry.filename or entry.value or entry[1])
              actions.close(prompt_bufnr)
              if not filepath then
                vim.notify("No file path found in selected Telescope entry", vim.log.levels.WARN)
                return
              end

              local img_clip = require("img-clip")
              img_clip.paste_image(nil, filepath)
            end

            map("i", "<CR>", embed_image)
            map("n", "<CR>", embed_image)

            return true
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
