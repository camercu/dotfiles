local function directory_finder(_opts, _ctx)
  local dirs = {}
  local fd = io.popen("fd --type d --hidden --exclude .git/ .", "r")
  if not fd then
    return dirs
  end
  for line in fd:lines() do
    table.insert(dirs, { file = line, text = line })
  end
  fd:close()
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
    { "<leader><space>", false },
    { "<space><space>", false },
  },
}
