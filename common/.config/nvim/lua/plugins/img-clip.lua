return {
  'HakonHarnes/img-clip.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  event = 'VeryLazy',
  keys = {
    { '<leader>ip', '<cmd>PasteImage<cr>', desc = 'Paste image from system clipboard' },
    {
      '<leader>if',
      function()
        local telescope = require('telescope.builtin')
        local actions = require('telescope.actions')
        local action_state = require('telescope.actions.state')

        telescope.find_files({
          attach_mappings = function(_, map)
            local function embed_image(prompt_bufnr)
              local entry = action_state.get_selected_entry()
              local filepath = entry[1]
              actions.close(prompt_bufnr)

              local img_clip = require('img-clip')
              img_clip.paste_image(nil, filepath)
            end

            map('i', '<CR>', embed_image)
            map('n', '<CR>', embed_image)

            return true
          end,
        })
      end,
      desc = 'Select image file to embed',
    },
  },
  opts = {
    drag_and_drop = {
      insert_mode = true,
    },
  },
}
