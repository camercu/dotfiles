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
          -- local-agent is an alias (common/.config/ollama) carrying its own
          -- 128K context; a raw tag would get the server's 8K default.
          -- keep_alive is left to the server, which pins loaded models.
          ollama = function()
            return require("codecompanion.adapters.http").extend("ollama", {
              schema = {
                model = { default = "local-agent" },
              },
            })
          end,
          -- Same model without thinking, for titles and commands: one model
          -- stays resident instead of swapping in a second one.
          ollama_quick = function()
            return require("codecompanion.adapters.http").extend("ollama", {
              schema = {
                model = { default = "local-agent" },
                think = { default = false },
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
          adapter = "ollama_quick",
          chat = {
            opts = {
              enabled = true, -- auto-generate chat buffer titles
            },
          },
        },
        cmd = {
          adapter = "ollama_quick",
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
