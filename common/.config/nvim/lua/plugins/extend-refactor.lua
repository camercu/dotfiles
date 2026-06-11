-- Rust support for refactoring.nvim (upstream has none).
-- Treesitter queries live in queries/rust/refactor_*.scm; code generation and
-- custom type directives live here. Tested by tests/test_rust_refactoring.lua
-- (run `make test` from the config root).
local iter = vim.iter

---@alias refactor.rust.Type string|vim.NIL|{identifier: string}|nil

---@param vars {identifier: string, type?: refactor.rust.Type}[]
---@return string
local function identifiers(vars)
  return iter(vars)
    :map(function(v)
      return v.identifier
    end)
    :join ", "
end

---@param s string
---@return string
local function fmt_escape(s)
  return (s:gsub("[{}]", { ["{"] = "{{", ["}"] = "}}" }):gsub('"', '\\"'))
end

---@param v {type?: refactor.rust.Type}
---@return string
local function type_of(v)
  -- non-strings (vim.NIL, unresolved {identifier} aliases) get a placeholder
  return type(v.type) == "string" and v.type or "_"
end

local rust_code_generation = {
  refactor = {
    extract_var = {
      code_generation = {
        variable_declaration = {
          rust = function(opts)
            return ("let %s = %s;"):format(opts.name, opts.value)
          end,
        },
      },
    },
    inline_var = {
      code_generation = {
        group_expression = {
          rust = function(opts)
            return ("(%s)"):format(opts.expression)
          end,
        },
      },
    },
    extract_func = {
      code_generation = {
        function_declaration = {
          rust = function(opts)
            local args = iter(opts.args)
              :map(function(v)
                return ("%s: %s"):format(v.identifier, type_of(v))
              end)
              :join ", "
            if opts.method then args = args ~= "" and ("&self, " .. args) or "&self" end
            local return_type = #opts.return_values == 0 and ""
              or #opts.return_values == 1 and (" -> %s"):format(type_of(opts.return_values[1]))
              or (" -> (%s)"):format(iter(opts.return_values):map(type_of):join ", ")
            return ([[
fn %s(%s)%s {
%s
}]]):format(opts.name, args, return_type, opts.body)
          end,
        },
        function_call = {
          rust = function(opts)
            local args = identifiers(opts.args)
            local name = opts.method and ("self.%s"):format(opts.name) or opts.name
            if #opts.return_values == 0 then return ("%s(%s);"):format(name, args) end
            if #opts.return_values == 1 then
              return ("let %s = %s(%s);"):format(opts.return_values[1].identifier, name, args)
            end
            return ("let (%s) = %s(%s);"):format(identifiers(opts.return_values), name, args)
          end,
        },
        return_statement = {
          rust = function(opts)
            if #opts.return_values == 1 then
              return ("\n\nreturn %s;"):format(opts.return_values[1].identifier)
            end
            return ("\n\nreturn (%s);"):format(identifiers(opts.return_values))
          end,
        },
      },
    },
    inline_func = {
      code_generation = {
        assignment = {
          rust = function(opts)
            if #opts.left == 0 then return "" end
            for i = #opts.right + 1, #opts.left do
              -- fewer values than bindings: make the gap loud but compilable
              opts.right[i] = "todo!()"
            end
            if #opts.left == 1 then return ("let %s = %s;"):format(opts.left[1], opts.right[1]) end
            return ("let (%s) = (%s);"):format(table.concat(opts.left, ", "), table.concat(opts.right, ", "))
          end,
        },
      },
    },
  },
  debug = {
    print_var = {
      code_generation = {
        print_var = {
          rust = function(opts)
            return ([[println!("%s %s %s: {:?}", %s);]]):format(
              fmt_escape(opts.debug_path),
              fmt_escape(opts.identifier_str),
              opts.count,
              opts.identifier
            )
          end,
        },
      },
    },
    print_loc = {
      code_generation = {
        print_loc = {
          rust = function(opts)
            return ([[println!("%s %s");]]):format(fmt_escape(opts.debug_path), opts.count)
          end,
        },
      },
    },
    print_exp = {
      code_generation = {
        print_exp = {
          rust = function(opts)
            return ([[println!("%s %s %s: {:?}", %s);]]):format(
              fmt_escape(opts.debug_path),
              fmt_escape(opts.expression_str),
              opts.count,
              opts.expression
            )
          end,
        },
      },
    },
  },
}

-- The plugin's #set-type!/#infer-type! directives hard-code per-language
-- handlers in its plugin/ts.lua and silently no-op for rust. Registering
-- rust-specific directives avoids clobbering the upstream ones.
local function register_rust_directives()
  local ts = vim.treesitter

  -- (#set-type-rust! @type-capture @identifier-capture)
  ts.query.add_directive("set-type-rust!", function(match, _, source, predicate, metadata)
    local types = match[predicate[2]]
    local idents = match[predicate[3]]
    if not (types and idents) then return end
    local result = {} ---@type string[]
    if #types == #idents then
      for i, node in ipairs(types) do
        result[i] = ts.get_node_text(node, source)
      end
    else
      local type_text = ts.get_node_text(types[1], source)
      for i = 1, #idents do
        result[i] = type_text
      end
    end
    metadata.types = result
  end, { force = true, all = true })

  local literal_types = {
    integer_literal = "i32",
    float_literal = "f64",
    string_literal = "&str",
    raw_string_literal = "&str",
    boolean_literal = "bool",
    char_literal = "char",
  }

  -- (#infer-type-rust! @value-capture)
  ts.query.add_directive("infer-type-rust!", function(match, _, source, predicate, metadata)
    local values = match[predicate[2]]
    if not values then return end
    local result = {} ---@type (string|{identifier: string}|vim.NIL)[]
    for i, node in ipairs(values) do
      if node:type() == "identifier" then
        -- resolved later through the identifier's own declaration
        result[i] = { identifier = ts.get_node_text(node, source) }
      else
        result[i] = literal_types[node:type()] or vim.NIL
      end
    end
    metadata.types = result
  end, { force = true, all = true })
end

-- inline_var/inline_func resolve symbols through LSP. Make that an optional
-- enhancement: when no attached client supports the request, fall back to a
-- treesitter-only resolution built from the plugin's own queries and helpers.
local function patch_lsp_helpers()
  local async = require "async"
  local utils = require "refactoring.utils"
  local ts = vim.treesitter

  ---@return vim.quickfix.entry[]?, vim.quickfix.entry[]?
  local function ts_locations()
    local buf = vim.api.nvim_get_current_buf()
    local node = ts.get_node { bufnr = buf }
    if not node or not node:type():find "identifier" then return end
    local lang_tree = ts.get_parser(buf, nil, { error = false })
    if not lang_tree then return end
    lang_tree:parse(true)
    local srow, scol = node:start()
    local nested_lang_tree = lang_tree:language_for_range { srow, scol, srow, scol }
    local lang = nested_lang_tree:lang()
    local reference_query = ts.query.get(lang, "refactor_reference")
    local scope_query = ts.query.get(lang, "refactor_scope")
    if not (reference_query and scope_query) then return end

    local references = utils.get_references(buf, nested_lang_tree, reference_query)
    local scopes = utils.get_scopes(buf, nested_lang_tree, scope_query)
    local declarations_by_scope = utils.get_declarations_by_scope(references, scopes, buf)

    local scope = utils.get_declaration_scope(declarations_by_scope, scopes, { identifier = node }, buf)
    if not scope then return end
    local text = ts.get_node_text(node, buf)
    local filename = vim.api.nvim_buf_get_name(buf)

    ---@param r {identifier: TSNode}
    ---@return vim.quickfix.entry
    local function to_entry(r)
      local start_row, start_col, end_row, end_col = r.identifier:range()
      return {
        filename = filename,
        lnum = start_row + 1,
        col = start_col + 1,
        end_lnum = end_row + 1,
        end_col = end_col + 1,
      }
    end
    ---@param entry vim.quickfix.entry
    local function by_position(entry)
      return ("%d:%d"):format(entry.lnum, entry.col)
    end

    local definitions = iter(declarations_by_scope[scope][text] or {}):map(to_entry):unique(by_position):totable()
    local references_for_text = iter(references)
      :filter(function(r)
        if r.declaration then return false end
        if ts.get_node_text(r.identifier, buf) ~= text then return false end
        return utils.get_declaration_scope(declarations_by_scope, scopes, r, buf) == scope
      end)
      :map(to_entry)
      :unique(by_position)
      :totable()
    return definitions, references_for_text
  end

  utils.get_lsp_definitions = async.wrap(2, function(_, cb)
    if #vim.lsp.get_clients { bufnr = 0, method = "textDocument/definition" } > 0 then
      vim.lsp.buf.definition {
        on_list = function(args)
          cb(args.items)
        end,
      }
      return
    end
    local definitions = ts_locations()
    cb(definitions or {})
  end)

  utils.get_lsp_references = async.wrap(2, function(_, cb)
    if #vim.lsp.get_clients { bufnr = 0, method = "textDocument/references" } > 0 then
      vim.lsp.buf.references({ includeDeclaration = false }, {
        on_list = function(args)
          cb(args.items)
        end,
      })
      return
    end
    local _, references = ts_locations()
    cb(references or {})
  end)
end

-- =====================================================================
-- rust-analyzer refactoring layer: extra <leader>r keys in rust buffers.
-- Common refactorings (rf/rx/ri) shadow the global refactoring.nvim maps
-- with a hybrid: rust-analyzer assist when a client is attached,
-- treesitter fallback otherwise. Menu keys surface only the assists valid
-- at the cursor (rust-analyzer filters by position). SSR/joinLines/
-- moveItem use rust-analyzer's experimental LSP extensions directly so
-- they work with any client setup (rustaceanvim or bare lspconfig).
-- =====================================================================

---@return vim.lsp.Client?
local function ra_client(buf)
  return vim.lsp.get_clients({ bufnr = buf or 0, method = "textDocument/codeAction" })[1]
end

-- NOTE: rust-analyzer reports generate_* assists with an EMPTY code action
-- kind (probed empirically), so the generate menu filters on kindless
-- actions instead of `only`
---@param opts {only?: string[], title?: string, kindless?: boolean}
local function ra_code_action(opts)
  return function()
    local filter
    if opts.title then
      filter = function(action)
        return action.title:find(opts.title, 1, true) ~= nil
      end
    elseif opts.kindless then
      filter = function(action)
        return not action.kind or action.kind == ""
      end
    end
    vim.lsp.buf.code_action {
      context = opts.only and { only = opts.only } or nil,
      filter = filter,
      apply = true,
    }
  end
end

-- expr-mapping hybrid: rust-analyzer assist when attached, else the
-- refactoring.nvim expr function (which returns keys to feed)
---@param ra_fn fun()
---@param ts_fn fun(): string
local function ra_or_treesitter(ra_fn, ts_fn)
  return function()
    if ra_client() then
      vim.schedule(ra_fn)
      return ""
    end
    return ts_fn()
  end
end

---@param s string snippet-format text (e.g. `fn $0foo()`)
---@return string plain text with snippet markers stripped
local function snippet_to_text(s)
  local text = s:gsub("%$%b{}", function(m)
    return m:match "^%${%d+:(.*)}$" or ""
  end)
  return (text:gsub("%$%d+", ""))
end

local function ra_join_lines()
  local client = ra_client()
  if not client then return end
  local buf = vim.api.nvim_get_current_buf()
  local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
  client:request("experimental/joinLines", {
    textDocument = params.textDocument,
    ranges = { params.range },
  }, function(err, result)
    if err or not result then return end
    vim.lsp.util.apply_text_edits(result, buf, client.offset_encoding)
  end)
end

---@param direction "Up"|"Down"
local function ra_move_item(direction)
  return function()
    local client = ra_client()
    if not client then return end
    local buf = vim.api.nvim_get_current_buf()
    local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
    params.direction = direction
    client:request("experimental/moveItem", params, function(err, result)
      if err or not result then return end
      -- result is SnippetTextEdit[]: strip snippet markers before applying
      for _, edit in ipairs(result) do
        if edit.insertTextFormat == 2 then edit.newText = snippet_to_text(edit.newText) end
        edit.insertTextFormat = nil
      end
      vim.lsp.util.apply_text_edits(result, buf, client.offset_encoding)
    end)
  end
end

-- structural search replace, e.g. `foo($a, $b) ==>> foo($b, $a)`
local function ra_ssr()
  local client = ra_client()
  if not client then return end
  vim.ui.input({ prompt = "SSR (search ==>> replace): " }, function(query)
    if not query or query == "" then return end
    local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
    params.query = query
    params.parseOnly = false
    params.selections = {}
    client:request("experimental/ssr", params, function(err, edit)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR, { title = "rust-analyzer ssr" })
        return
      end
      if edit then vim.lsp.util.apply_workspace_edit(edit, client.offset_encoding) end
    end)
  end)
end

---@param buf integer
local function attach_rust_keymaps(buf)
  ---@param mode string|string[]
  local function map(mode, lhs, rhs, desc, expr)
    vim.keymap.set(mode, lhs, rhs, { buffer = buf, desc = desc, expr = expr })
  end

  -- hybrid keys: shadow the global refactoring.nvim maps. Extract assists
  -- need a selection, so only the visual maps go rust-analyzer-first; the
  -- normal-mode operator maps stay treesitter.
  map(
    { "n", "x" },
    "<leader>ri",
    ra_or_treesitter(ra_code_action { only = { "refactor.inline" } }, function()
      return require("refactoring").inline_var()
    end),
    "Inline (rust-analyzer)",
    true
  )
  map(
    "x",
    "<leader>rf",
    ra_or_treesitter(ra_code_action { only = { "refactor.extract" }, title = "Extract into function" }, function()
      return require("refactoring").extract_func()
    end),
    "Extract Function (rust-analyzer)",
    true
  )
  map(
    "x",
    "<leader>rx",
    ra_or_treesitter(ra_code_action { only = { "refactor.extract" }, title = "Extract into variable" }, function()
      return require("refactoring").extract_var()
    end),
    "Extract Variable (rust-analyzer)",
    true
  )

  -- category menus: cursor-filtered, auto-apply when only one assist matches
  map({ "n", "x" }, "<leader>re", ra_code_action { only = { "refactor.extract" } }, "RA Extract…")
  map({ "n", "x" }, "<leader>rw", ra_code_action { only = { "refactor.rewrite" } }, "RA Rewrite…")
  map({ "n", "x" }, "<leader>rg", ra_code_action { kindless = true }, "RA Generate…")
  map({ "n", "x" }, "<leader>rr", ra_code_action {}, "RA All Assists…")

  -- rust-analyzer LSP extensions
  map("n", "<leader>rS", ra_ssr, "RA Structural Search Replace")
  map({ "n", "x" }, "<leader>rj", ra_join_lines, "RA Join Lines")
  map("n", "<leader>rM", ra_move_item "Up", "RA Move Item Up")
  map("n", "<leader>rm", ra_move_item "Down", "RA Move Item Down")
end

local function setup_rust_keymaps()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "rust",
    group = vim.api.nvim_create_augroup("refactor-rust-analyzer", { clear = true }),
    callback = function(ev)
      attach_rust_keymaps(ev.buf)
    end,
  })
  -- buffers opened before the plugin loaded
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].filetype == "rust" then attach_rust_keymaps(buf) end
  end
end

return {
  "ThePrimeagen/refactoring.nvim",
  -- load in rust buffers so the rust-analyzer keymap layer attaches even
  -- before any global <leader>r key is pressed
  ft = "rust",
  opts = rust_code_generation,
  config = function(_, opts)
    require("refactoring").setup(opts)
    register_rust_directives()
    patch_lsp_helpers()
    setup_rust_keymaps()
  end,
}
