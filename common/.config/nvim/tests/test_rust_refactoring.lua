---@module "mini.test"

local child = MiniTest.new_child_neovim()

local eq = MiniTest.expect.equality

local T = MiniTest.new_set {
  hooks = {
    pre_case = function()
      child.restart { "-u", "tests/minimal_init.lua" }
      child.bo.readonly = false
      child.lua "vim.notify = function(msg, level) if level == vim.log.levels.ERROR then error(msg) end end"
      child.lua [[
vim.api.nvim_create_autocmd('Filetype', {
  pattern = 'rust',
  command = 'setlocal expandtab shiftwidth=4'
})
]]
    end,
    post_once = child.stop,
  },
}

---@param lines string
local set_lines = function(lines)
  child.api.nvim_buf_set_lines(0, 0, -1, true, vim.split(lines, "\n"))
end

local get_lines = function()
  return child.api.nvim_buf_get_lines(0, 0, -1, true)
end

---@param lines string
---@param cursor {[1]: integer, [2]: integer}
---@param expected_lines string
---@param ... string
local function validate(lines, cursor, expected_lines, ...)
  set_lines(lines)
  child.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] })
  child.type_keys(...)
  -- refactorings apply asynchronously; poll until the buffer settles
  local expected = vim.split(expected_lines, "\n")
  for _ = 1, 25 do
    if vim.deep_equal(get_lines(), expected) then break end
    vim.uv.sleep(200)
    child.api.nvim_eval "1" -- poke child's event loop
  end
  eq(get_lines(), expected)
end

---@param path string
---@return string
local function read_file(path)
  local file = io.open(path)
  assert(file)
  local lines = file:read("*a"):gsub("\n$", "") ---@type string
  return lines
end

---@param name string
---@return string, string
local function fixture(name)
  return read_file(("./tests/files/%s_before.rs"):format(name)), read_file(("./tests/files/%s_after.rs"):format(name))
end

local wait_quiescent = function()
  child.lua [[
    vim.wait(60000, function()
      return vim.g.ra_quiescent == true
    end, 500)
  ]]
end

-- For rust-analyzer-driven actions (code actions, LSP extensions): wait for
-- the indexer to go quiescent, fire the keys, poll until the buffer settles.
---@param lines string
---@param cursor {[1]: integer, [2]: integer}
---@param expected_lines string
---@param ... string
local function validate_ra(lines, cursor, expected_lines, ...)
  set_lines(lines)
  child.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] })
  wait_quiescent()
  child.type_keys(...)
  local expected = vim.split(expected_lines, "\n")
  for _ = 1, 75 do
    if vim.deep_equal(get_lines(), expected) then break end
    vim.uv.sleep(200)
    child.api.nvim_eval "1" -- poke child's event loop
  end
  eq(get_lines(), expected)
end

-- For refactorings that resolve symbols through LSP (inline_var, inline_func):
-- waits for rust-analyzer to resolve a definition at the cursor, fires the
-- keys, then polls until the buffer settles on the expected result.
---@param lines string
---@param cursor {[1]: integer, [2]: integer}
---@param expected_lines string
---@param ... string
local function validate_lsp(lines, cursor, expected_lines, ...)
  set_lines(lines)
  child.api.nvim_win_set_cursor(0, { cursor[1], cursor[2] })
  -- rust-analyzer resolves references incrementally (refs inside macros land
  -- only once indexing is quiescent), so wait for its serverStatus signal,
  -- then for references at the cursor to resolve
  wait_quiescent()
  child.lua [[
    vim.wait(10000, function()
      local params = vim.lsp.util.make_position_params(0, "utf-8")
      params.context = { includeDeclaration = false }
      local res = vim.lsp.buf_request_sync(0, "textDocument/references", params, 2000)
      if not res then return false end
      for _, r in pairs(res) do
        if r.result and #r.result > 0 then return true end
      end
      return false
    end, 1000)
  ]]
  child.type_keys(...)
  local expected = vim.split(expected_lines, "\n")
  for _ = 1, 75 do
    if vim.deep_equal(get_lines(), expected) then break end
    vim.uv.sleep(200)
    child.api.nvim_eval "1" -- poke child's event loop
  end
  eq(get_lines(), expected)
end

T["extract_var"] = MiniTest.new_set {}

T["extract_var"]["works"] = function()
  local before, after = fixture "extract_var_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 0 }, after, " avi)", "foo<cr>")
end

T["extract_var"]["replaces all identical occurrences in scope"] = function()
  local before, after = fixture "extract_var_multiple_occurrences"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 0 }, after, " avi)", "foo<cr>")
end

T["extract_var"]["inside match arm value"] = function()
  local before, after = fixture "extract_var_match_arm"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 4, 0 }, after, " avi)", "foo<cr>")
end

T["extract_var"]["from expression-body closure"] = function()
  local before, after = fixture "extract_var_closure"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 0 }, after, " avi)", "foo<cr>")
end

T["extract_func"] = MiniTest.new_set {}

T["extract_func"]["works"] = function()
  local before, after = fixture "extract_func_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 5, 0 }, after, " aeip", "add<cr>")
end

T["extract_func"]["method"] = function()
  local before, after = fixture "extract_func_method"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 9, 0 }, after, " aeip", "show<cr>")
end

T["extract_func"]["inside mod block"] = function()
  local before, after = fixture "extract_func_mod"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 11, 0 }, after, " aeip", "add<cr>")
end

T["extract_func"]["tuple-declared args"] = function()
  local before, after = fixture "extract_func_tuple_args"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 4, 0 }, after, " aeip", "sum<cr>")
end

T["inline_var"] = MiniTest.new_set {}

T["inline_var"]["works"] = function()
  local before, after = fixture "inline_var_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_lsp(before, { 2, 8 }, after, " ai")
end

T["inline_var"]["tuple element"] = function()
  local before, after = fixture "inline_var_tuple"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 9 }, after, " ai")
end

T["inline_var"]["use in cast expression"] = function()
  local before, after = fixture "inline_var_cast"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 8 }, after, " ai")
end

T["inline_var"]["works without LSP via treesitter fallback"] = function()
  local before, after = fixture "inline_var_works"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 8 }, after, " ai")
end

T["extract_func"]["multiple return values become a tuple"] = function()
  local before, after = fixture "extract_func_multi_return"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 4, 0 }, after, " aeip", "pair<cr>")
end

T["extract_func"]["mut variable becomes arg and return value"] = function()
  local before, after = fixture "extract_func_mut"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 4, 0 }, after, " aeip", "step<cr>")
end

T["inline_func"] = MiniTest.new_set {}

T["inline_func"]["works"] = function()
  local before, after = fixture "inline_func_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_lsp(before, { 7, 12 }, after, " aI")
end

T["inline_func"]["tail expression without LSP via treesitter fallback"] = function()
  local before, after = fixture "inline_func_tail"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 6, 12 }, after, " aI")
end

T["inline_func"]["no args and no return value"] = function()
  local before, after = fixture "inline_func_no_args"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 6, 4 }, after, " aI")
end

-- rust-analyzer layer: <leader>r keys defined in extend-refactor.lua
T["rust-analyzer"] = MiniTest.new_set {}

-- NOTE: rust-analyzer's inline assist triggers from a USAGE position and
-- inlines that occurrence (declaration stays while other usages remain);
-- treesitter inline_var triggers from the declaration and inlines all usages
T["rust-analyzer"]["inline via code action"] = function()
  local before, after = fixture "ra_inline"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_ra(before, { 3, 12 }, after, " ri")
end

T["rust-analyzer"]["inline falls back to treesitter without LSP"] = function()
  local before, after = fixture "inline_var_works"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 8 }, after, " ri")
end

T["rust-analyzer"]["extract function from visual selection"] = function()
  local before, after = fixture "ra_extract_func"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_ra(before, { 4, 0 }, after, "Vj", " rf")
end

T["rust-analyzer"]["extract variable falls back to treesitter without LSP"] = function()
  local before, after = fixture "extract_var_works"
  child.lua "vim.lsp.enable('rust_analyzer', false)"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 13 }, after, "vi)", " rx", "foo<cr>")
end

T["rust-analyzer"]["generate menu offers kindless assists"] = function()
  local before, after = fixture "ra_generate_new"
  child.cmd "edit tests/sandbox/src/main.rs"
  child.lua [[
    vim.ui.select = function(items, opts, cb)
      for _, item in ipairs(items) do
        local text = opts.format_item and opts.format_item(item) or tostring(item)
        if text:find("`new`", 1, true) then return cb(item) end
      end
      cb(nil)
    end
  ]]
  validate_ra(before, { 1, 7 }, after, " rg")
end

T["rust-analyzer"]["join lines"] = function()
  local before, after = fixture "ra_join_lines"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_ra(before, { 2, 8 }, after, " rj")
end

T["rust-analyzer"]["join lines over visual selection"] = function()
  local before, after = fixture "ra_join_lines_visual"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_ra(before, { 2, 0 }, after, "Vjj", " rj")
end

T["rust-analyzer"]["move item up"] = function()
  local before, after = fixture "ra_move_item"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate_ra(before, { 3, 3 }, after, " rM")
end

T["rust-analyzer"]["structural search replace"] = function()
  local before, after = fixture "ra_ssr"
  child.cmd "edit tests/sandbox/src/main.rs"
  child.lua [[
    vim.ui.input = function(_, cb)
      cb "add($a, $b) ==>> add($b, $a)"
    end
  ]]
  validate_ra(before, { 6, 0 }, after, " rS")
end

T["debug"] = MiniTest.new_set {}

T["debug"]["print_var works"] = function()
  local before, after = fixture "print_var_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 8 }, after, " pviw")
end

-- NOTE: print_var on a macro argument (e.g. foo inside `println!("{}", foo)`)
-- is unsupported: the macro token_tree gets a nested rust language injection
-- and the plugin resolves declarations only within the injected tree
T["debug"]["print_loc inside nested scope shows path"] = function()
  local before, after = fixture "print_loc_nested"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 4, 8 }, after, " pp")
end

T["debug"]["print_loc works"] = function()
  local before, after = fixture "print_loc_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 2, 8 }, after, " pp")
end

T["debug"]["print_exp works"] = function()
  local before, after = fixture "print_exp_works"
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 3, 14 }, after, " peiw")
end

T["debug"]["cleanup removes printed statements"] = function()
  local after, before = fixture "print_var_works" -- inverse of print_var
  child.cmd "edit tests/sandbox/src/main.rs"
  validate(before, { 1, 0 }, after, "VG", " pc")
end

return T
