-- LLM code block response format
local response_format = "Respond EXACTLY in this format:\n```$ftype\n<your code>\n```"

return {
  -- disable all online LLM tools
  { "github/copilot.vim", enabled = false },
  { "zbirenbaum/copilot.lua", enabled = false },
  { "Exafunction/codeium.nvim", enabled = false },

  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },

    init = function()
      vim.cmd("cnoreabbrev cc CodeCompanion") -- inline prompt
      vim.cmd("cnoreabbrev ccc CodeCompanionChat")
    end,

    keys = {
      { "<leader>cp", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions picker" },
      {
        "<LocalLeader>c",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Chat Toggle",
      },
      {
        "<LocalLeader>a",
        "<cmd>CodeCompanionChat Add<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Chat Add <selection>",
      },
    },
    opts = {

      adapters = {
        http = {
          ollama = function()
            return require("codecompanion.adapters.http").extend("ollama", {
              schema = {
                model = {
                  default = "glm-4.7-flash:latest",
                },
              },
            })
          end,
        },
        acp = {
          opencode = function()
            return require("codecompanion.adapters.acp").extend("opencode", {
              schema = {
                model = {
                  default = "anthropic/claude-opus-4-6/high",
                },
              },
            })
          end,

          claude_code = function()
            local command

            if vim.fn.executable("claude-code-acp") == 1 then
              command = { vim.fn.exepath("claude-code-acp") }
            elseif vim.fn.executable("npx") == 1 then
              command = { "npx", "-y", "claude-code-acp" }
            else
              vim.schedule(function()
                vim.notify(
                  "CodeCompanion claude_code adapter requires `claude-code-acp` or `npx`.",
                  vim.log.levels.ERROR
                )
              end)
              command = { "claude-code-acp" }
            end

            return require("codecompanion.adapters.acp").extend("claude_code", {
              commands = {
                default = command,
              },
              env = {
                CLAUDE_CODE_OAUTH_TOKEN = os.getenv("CLAUDE_CODE_OAUTH_TOKEN"),
              },
              schema = {
                model = {
                  default = "anthropic/claude-opus-4-6/high",
                },
              },
            })
          end,

          codex = function()
            local command

            if vim.fn.executable("codex-acp") == 1 then
              command = { vim.fn.exepath("codex-acp") }
            elseif vim.fn.executable("npx") == 1 then
              command = { "npx", "-y", "@zed-industries/codex-acp" }
            else
              vim.schedule(function()
                vim.notify("CodeCompanion Codex adapter requires `codex-acp` or `npx`.", vim.log.levels.ERROR)
              end)
              command = { "codex-acp" }
            end

            return require("codecompanion.adapters.acp").extend("codex", {
              commands = {
                default = command,
              },
              defaults = {
                auth_method = "chatgpt", -- "openai-api-key"|"codex-api-key"|"chatgpt"
              },
              env = {
                OPENAI_API_KEY = os.getenv("OPENAI_API_KEY"),
                CODEX_API_KEY = os.getenv("CODEX_API_KEY"),
              },
              schema = {
                model = {
                  default = "gpt-5.3-codex/high",
                },
              },
            })
          end,
        },
      },

      interactions = {
        chat = {
          adapter = "opencode",
        },
        inline = {
          adapter = "opencode",
        },
        background = {
          adapter = "ollama",
        },
        cmd = {
          adapter = {
            name = "ollama",
            model = "qwen2.5-coder:7b-base-q6_K",
          },
        },
      },

      prompt_library = {
        markdown = {
          dirs = {
            vim.fn.getcwd() .. "/.prompts", -- Can be relative
            "~/.config/codecompanion/prompts", -- Or absolute paths
          },
        },
      },
    },
  },
}
