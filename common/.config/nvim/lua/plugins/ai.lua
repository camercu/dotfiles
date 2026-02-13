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
    opts = {
      adapters = {
        ollama = function()
          return require("codecompanion.adapters").extend("ollama", {
            schema = {
              model = {
                default = "glm-4.7-flash:latest",
              },
            },
          })
        end,
        acp = {
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

            return require("codecompanion.adapters").extend("codex", {
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
            })
          end,
        },
      },
      interactions = {
        chat = {
          adapter = "ollama",
        },
        inline = {
          adapter = {
            name = "ollama",
            model = "codellama:7b-code",
          },
        },
        background = {
          adapter = {
            name = "ollama",
            model = "ministral-3:14b",
          },
        },
        cmd = {
          adapter = "ollama",
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
