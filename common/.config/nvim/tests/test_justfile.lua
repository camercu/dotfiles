---@module "mini.test"

local child = MiniTest.new_child_neovim()

local eq = MiniTest.expect.equality

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "NONE" }
      child.o.smartindent = true -- LazyVim default
      child.lua 'dofile "lua/config/autocmds.lua"'
    end,
    post_once = child.stop,
  },
}

T[">> indents a comment line in a justfile"] = function()
  child.bo.filetype = "just"
  child.api.nvim_buf_set_lines(0, 0, -1, true, { "# comment" })

  child.type_keys ">>"

  eq(child.api.nvim_get_current_line(), "\t# comment")
end

T["comment leader stays set in a justfile"] = function()
  child.cmd "filetype plugin on"

  child.bo.filetype = "just"

  eq(child.bo.comments ~= "", true)
end

return T
