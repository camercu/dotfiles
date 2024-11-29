-- Use Coerce to coerce words into various cases.
-- https://github.com/gregorias/coerce.nvim
return {
  'gregorias/coerce.nvim',
  tag = 'v3.0.0',
  opts = {
    default_mode_keymap_prefixes = {
      normal_mode = 'cu',
      motion_mode = 'gcu',
      visual_mode = 'gcu',
    },
  },
  config = function(_, opts)
    require('coerce').setup(opts)
    require('coerce').register_case({
      keymap = 'l',
      case = function(str)
        return vim.fn.tolower(str)
      end,
      description = 'lowercase',
    })
  end,
}
