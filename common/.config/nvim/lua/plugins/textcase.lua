-- coerce.nvim's breaking-change release (11f0282, "expose keymap bindings")
-- dropped the old `default_mode_keymap_prefixes` DSL in favor of wiring the
-- <Plug> maps yourself. `opts.default_mode_keymap_prefixes` is unread by the
-- current plugin, so it was a silent no-op: `ga`/`gao` were never bound.
-- Wired directly here, same prefixes as before, plus which-key labels for
-- each case (was previously unlabeled/absent in which-key too).
--
-- Title Case / Sentence case used to be standalone `gat`/`gaT` keymaps
-- (config/keymaps.lua) that ran a whole-line regex substitution. Coerce has
-- no built-in case for either, but shares the same `ga` prefix, so those two
-- didn't show up in the which-key popup and only acted on the whole line
-- instead of word/motion/selection like every real coerce case. Registered
-- here as proper coerce cases instead: reuses coerce's own keyword splitter
-- and grapheme-safe capitalization, so `t`/`T` get which-key labels and work
-- under `ga` (word), `gao` (motion), and visual `ga` (selection) alike.
return {
  "gregorias/coerce.nvim",
  dependencies = { "gregorias/coop.nvim" },
  version = "*",
  config = function(_, opts)
    local case = require("coerce.case")
    local cs = require("coerce.string")

    local function capitalize(part)
      local graphemes = cs.str2graphemelist(part)
      graphemes[1] = vim.fn.toupper(graphemes[1])
      return table.concat(graphemes, "")
    end

    local function to_title_case(str)
      return table.concat(vim.tbl_map(capitalize, case.split_keyword(str)), " ")
    end

    local function to_sentence_case(str)
      local parts = case.split_keyword(str)
      if parts[1] then
        parts[1] = capitalize(parts[1])
      end
      return table.concat(parts, " ")
    end

    opts.cases = vim.list_extend(vim.deepcopy(require("coerce").default_cases), {
      { keymap = "t", case = to_title_case, description = "Title Case" },
      { keymap = "T", case = to_sentence_case, description = "Sentence case" },
    })

    require("coerce").setup(opts)

    vim.keymap.set("n", "ga", "<Plug>(coerce-normal)", { desc = "Coerce word" })
    vim.keymap.set("n", "gao", "<Plug>(coerce-motion)", { desc = "Coerce motion" })
    vim.keymap.set("x", "ga", "<Plug>(coerce-visual)", { desc = "Coerce selection" })

    local ok, wk = pcall(require, "which-key")
    if not ok then return end
    local wke = require("coerce.keymaps").which_key_expand
    wk.add({
      { "ga", group = "+Coerce word", expand = wke.normal_mode, mode = "n" },
      { "gao", group = "+Coerce motion", expand = wke.motion_mode, mode = "n" },
      { "ga", group = "+Coerce selection", expand = wke.visual_mode, mode = "x" },
    })
  end,
}
