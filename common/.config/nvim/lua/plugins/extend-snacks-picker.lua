local function directory_finder(_opts, _ctx)
  local dirs = {}

  if vim.fn.executable("fd") ~= 1 then
    vim.notify("`fd` is not installed; directory picker is unavailable", vim.log.levels.WARN)
    return dirs
  end

  local proc = vim.system({ "fd", "--type", "d", "--hidden", "--exclude", ".git", "." }, { text = true }):wait()
  if proc.code ~= 0 then
    vim.notify("Failed to list directories with fd", vim.log.levels.WARN)
    return dirs
  end

  for line in vim.gsplit(proc.stdout or "", "\n", { trimempty = true }) do
    table.insert(dirs, { file = line, text = line })
  end

  return dirs
end

return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      matcher = {
        frecency = true, -- sort results by most often/recently used
        history_bonus = false, -- give more weight to chronological order
      },
      debug = {
        scores = false, -- set to true to show frecency scores
      },
    },
  },
  keys = {
    {
      "<leader>fd",
      function()
        require("snacks").picker.pick({
          title = "Find Directories",
          layout = "select",
          finder = directory_finder,
        })
      end,
      desc = "Find Directories",
    },
    -- Disable Snacks' default <leader><leader> picker mapping so config/keymaps.lua can own it.
    { "<leader><leader>", false },
  },
}
