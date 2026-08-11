return {
  "olimorris/codecompanion.nvim",
  version = "^19.0.0",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  opts = {
    adapters = {
      http = {
        deepseek_flash = function()
          return require("codecompanion.adapters").extend("openai_compatible", {
            env = {
              url = "https://opencode.ai/zen/go",
              chat_url = "/v1/chat/completions",
              api_key = "cmd:op read 'op://Development/opencode_go/credential' --no-newline",
            },
            schema = {
              model = {
                default = "deepseek-v4-flash",
                choices = {
                  ["deepseek-v4-flash"] = {
                    formatted_name = "DeepSeek V4 Flash",
                  },
                },
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
      cli = {
        agent = "opencode",
        agents = {
          claude_code = {
            cmd = "claude",
            args = {},
            description = "Claude Code CLI",
            provider = "terminal",
          },
          opencode = {
            cmd = "opencode",
            args = {},
            description = "Opencode CLI",
            provider = "terminal",
          },
        },
      },
      cmd = {
        adapter = "deepseek_flash",
      },
      inline = {
        adapter = "deepseek_flash",
      },
    },
  },
  init = function()
    vim.keymap.set({ "n", "v" }, "<C-a>", "<cmd>CodeCompanionActions<cr>", { noremap = true, silent = true })
    vim.keymap.set(
      { "n", "v" },
      "<LocalLeader>a",
      "<cmd>CodeCompanionChat Toggle<cr>",
      { noremap = true, silent = true }
    )
    vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>", { noremap = true, silent = true })

    -- Expand 'cc' into 'CodeCompanion' in the command line
    vim.cmd([[cab cc CodeCompanion]])
  end,
}
