local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end

return {
  "LazyVim/LazyVim",
  keys = {
    -- disabled keymaps
    { "", false },

    -- fix label on default keymaps
    { "<leader>fn", "<cmd>enew<cr>", desc = "[F]ile [N]ew" },
    { "[b", "<cmd>bprevious<cr>", desc = "Previous Buffer" },
    { "[d", diagnostic_goto(false), desc = "Previous Diagnostic" },
    { "[e", diagnostic_goto(false, "ERROR"), desc = "Previous Error" },
    { "[w", diagnostic_goto(false, "WARN"), desc = "Previous Warning" },
  },
}
