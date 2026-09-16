-- coerce.nvim's breaking-change release (11f0282, "expose keymap bindings")
-- dropped the old `default_mode_keymap_prefixes` DSL in favor of wiring the
-- <Plug> maps yourself. `opts.default_mode_keymap_prefixes` is unread by the
-- current plugin, so it was a silent no-op: `ga`/`gao` were never bound.
-- Wired directly here, same prefixes as before, plus which-key labels for
-- each case (was previously unlabeled/absent in which-key too).
return {
  "gregorias/coerce.nvim",
  dependencies = { "gregorias/coop.nvim" },
  version = "*",
  config = function(_, opts)
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
