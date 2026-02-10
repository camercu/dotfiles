local kind_icons = {
  -- LLM Provider icons
  claude = "󰋦",
  openai = "󱢆",
  codestral = "󱎥",
  gemini = "",
  grok = "",
  openrouter = "󱂇",
  Ollama = "󰳆",
  ["Llama.cpp"] = "󰳆",
  Deepseek = "",
}

local source_icons = {
  minuet = "󱗻",
  orgmode = "",
  otter = "󰼁",
  nvim_lsp = "",
  lsp = "",
  buffer = "",
  luasnip = "",
  snippets = "",
  path = "",
  git = "",
  tags = "",
  cmdline = "󰘳",
  latex_symbols = "",
  cmp_nvim_r = "󰟔",
  codeium = "󰩂",
  -- FALLBACK
  fallback = "󰜚",
}

local request_timeout = 3 -- seconds

return {

  {
    "saghen/blink.cmp",
    lazy = true,
    dependencies = {
      "saghen/blink.compat",
      "milanglacier/minuet-ai.nvim",
      "allaman/emoji.nvim",
      "olimorris/codecompanion.nvim",
    },
    opts = {
      keymap = {
        preset = "super-tab",
        ["<Tab>"] = {
          require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
          require("lazyvim.util.cmp").map({ "snippet_forward", "ai_accept" }),
          "fallback",
        },
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "emoji", "minuet", "codecompanion" },
        per_filetype = {
          codecompanion = { "codecompanion" },
        },
        providers = {
          emoji = {
            name = "emoji",
            module = "blink.compat.source",
            transform_items = function(_, items)
              local kind = require("blink.cmp.types").CompletionItemKind.Text
              for i = 1, #items do
                items[i].kind = kind
              end
              return items
            end,
          },
          minuet = {
            name = "minuet",
            module = "minuet.blink",
            async = true,
            -- Should match minuet.config.request_timeout * 1000,
            -- since minuet.config.request_timeout is in seconds
            timeout_ms = request_timeout * 1000,
            score_offset = 50, -- Gives minuet higher priority among suggestions
          },
        },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "normal",
        kind_icons = kind_icons,
      },
      completion = {
        -- Recommended to avoid unnecessary request
        trigger = { prefetch_on_insert = false },
        menu = {
          draw = {
            columns = {
              { "kind_icon", "source_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
            components = {
              source_icon = {
                -- don't truncate source_icon
                ellipsis = false,
                text = function(ctx)
                  return source_icons[ctx.source_name:lower()] or source_icons.fallback
                end,
                highlight = "BlinkCmpSource",
              },
            },
          },
        },
      },
    },
  },

  -- AI code compeltion with local LLM (Ollama)
  {
    "milanglacier/minuet-ai.nvim",
    lazy = true,
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      provider = "openai_fim_compatible",
      n_completions = 1, -- recommend for local model for resource saving
      -- I recommend beginning with a small context window size and incrementally
      -- expanding it, depending on your local computing power. A context window
      -- of 512, serves as an good starting point to estimate your computing
      -- power. Once you have a reliable estimate of your local computing power,
      -- you should adjust the context window to a larger value.
      context_window = 4096,
      request_timeout = request_timeout,
      provider_options = {
        openai_fim_compatible = {
          -- For Windows users, TERM may not be present in environment variables.
          -- Consider using APPDATA instead.
          api_key = function()
            return "not required for ollama"
          end,
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:7b-base-q6_K",
          -- model = "codellama:7b-code",
          optional = {
            max_tokens = 256,
            stop = { "\n\n" },
          },
        },
      },
    },
  },
}
