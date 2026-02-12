return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      nixd = {
        settings = {
          nixd = {
            formatting = {
              command = { "nixfmt" },
            },
            nixpkgs = {
              expr = "import <nixpkgs> {}",
            },
            options = {
              nixos = {
                expr = "(builtins.getFlake \"/home/sirwayne/dotfiles/nix\").nixosConfigurations.kirby.options",
              },
              home_manager = {
                expr = "(builtins.getFlake \"/home/sirwayne/dotfiles/nix\").homeConfigurations.\"sirwayne@kirby\".options",
              },
            },
          },
        },
      },
    },
  },
}
