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
