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
        minimax = function()
          return require("codecompanion.adapters").extend("anthropic", {
            url = "https://opencode.ai/zen/go/v1/messages", -- The endpoint from your image
            env = {
              api_key = "cmd:op read 'op://Development/opencode_go/credential' --no-newline",
            },
            schema = {
              model = {
                default = "minimax-m2.7", -- The Model ID from your image
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
        adapter = "minimax",
      },
      inline = {
        adapter = "minimax",
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
