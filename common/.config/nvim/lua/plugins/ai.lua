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

      local ok, wk = pcall(require, "which-key")
      if ok then
        wk.add({ "<leader>a", group = "ai" })
      end
    end,

    -- claudecode.nvim used to own <leader>a*; freed up when it was removed
    -- in favor of this plugin's own claude_code adapter.
    keys = {
      { "<leader>ap", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions picker" },
      {
        "<leader>ac",
        "<cmd>CodeCompanionChat Toggle<cr>",
        mode = { "n", "v" },
        desc = "CodeCompanion Chat Toggle",
      },
      {
        "<leader>aa",
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
                  default = "qwen3.8:27b-mlx",
                },
                keep_alive = {
                  default = "1h",
                },
              },
            })
          end,
        },
        acp = {
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
                CLAUDE_MODEL = "opus",
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
          adapter = "ollama",
        },
        background = {
          adapter = {
            name = "ollama",
            model = "qwen2.5-coder:latest",
          },
          chat = {
            opts = {
              enabled = true, -- auto-generate chat buffer titles
            },
          },
        },
        cmd = {
          adapter = {
            name = "ollama",
            model = "qwen2.5-coder:latest",
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
