local PREFIX = 'ga'
local OPER_PREFIX = 'o'
local LINE_PREFIX = 'a'

local function setup_default_keymappings()
  local whichkey = require('textcase.extensions.whichkey')
  whichkey.register_prefix('x', PREFIX, 'text-case')
  whichkey.register_prefix('n', PREFIX, 'text-case')
  whichkey.register_prefix('n', PREFIX .. OPER_PREFIX, 'Pending mode operator')
  whichkey.register_prefix('n', PREFIX .. LINE_PREFIX, 'Linewise convert')

  local default_keymapping_definitions = {
    { method_name = 'to_upper_case', quick_replace = 'u', operator = OPER_PREFIX .. 'u', lsp_rename = 'U' },
    { method_name = 'to_lower_case', quick_replace = 'l', operator = OPER_PREFIX .. 'l', lsp_rename = 'L' },
    { method_name = 'to_snake_case', quick_replace = 's', operator = OPER_PREFIX .. 's', lsp_rename = 'S' },
    { method_name = 'to_constant_case', quick_replace = 'n', operator = OPER_PREFIX .. 'n', lsp_rename = 'N' },
    { method_name = 'to_camel_case', quick_replace = 'c', operator = OPER_PREFIX .. 'c', lsp_rename = 'C' },
    { method_name = 'to_pascal_case', quick_replace = 'p', operator = OPER_PREFIX .. 'p', lsp_rename = 'P' },
    { method_name = 'to_dash_case', quick_replace = 'd', operator = OPER_PREFIX .. 'd', lsp_rename = 'D' },
    { method_name = 'to_dot_case', quick_replace = '.', operator = OPER_PREFIX .. '.' },
    { method_name = 'to_comma_case', quick_replace = ',', operator = OPER_PREFIX .. ',' },
    { method_name = 'to_title_case', quick_replace = 't', operator = OPER_PREFIX .. 't', lsp_rename = 'T' },
    { method_name = 'to_phrase_case', quick_replace = 'h', operator = OPER_PREFIX .. 'h', lsp_rename = 'H' },
  }

  local tc = require('textcase')
  for _, keymapping_definition in ipairs(default_keymapping_definitions) do
    tc.register_keybindings(PREFIX, tc.api[keymapping_definition.method_name], {
      prefix = PREFIX,
      quick_replace = keymapping_definition.quick_replace,
      operator = keymapping_definition.operator,
      lsp_rename = keymapping_definition.lsp_rename,
    })
  end
end

return {
  'johmsalas/text-case.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  version = '*',
  config = function(_, opts)
    require('textcase').setup(opts)
    require('telescope').load_extension('textcase')
    setup_default_keymappings()
  end,
  opts = {
    prefix = PREFIX,
    default_keymappings_enabled = false,
  },
  keys = {
    { PREFIX .. 'f', '<cmd>TextCaseOpenTelescope<CR>', mode = { 'n', 'x' }, desc = 'Telescope' },
  },
  cmd = {
    -- NOTE: The Subs command name can be customized via the option "substitude_command_name"
    'Subs',
    'TextCaseOpenTelescope',
    'TextCaseOpenTelescopeQuickChange',
    'TextCaseOpenTelescopeLSPChange',
    'TextCaseStartReplacingCommand',
  },

  -- If you want to use the interactive feature of the `Subs` command right away, text-case.nvim
  -- has to be loaded on startup. Otherwise, the interactive feature of the `Subs` will only be
  -- available after the first executing of it or after a keymap of text-case.nvim has been used.
  lazy = false,
}
-- return {
--   'gregorias/coerce.nvim',
--   version = '*',
--   opts = {
--     default_mode_keymap_prefixes = {
--       normal_mode = 'ga',
--       motion_mode = 'gao',
--       visual_mode = 'ga',
--     },
--   },
-- }
