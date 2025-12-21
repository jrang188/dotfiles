return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      nil_ls = {},
    },
    setup = {
      settings = {
        ["nil"] = {
          formatting = {
            command = { "nixfmt" },
          },
          nix = {
            flake = {
              autoArchive = true,
            },
          },
        },
      },
    },
  },
}
