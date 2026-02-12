local flake_path = vim.fn.expand("~/dotfiles/nix")
local hostname = (vim.loop.os_gethostname() or ""):gsub("%..*$", "")
local username = vim.env.USER or "sirwayne"
local is_darwin = (vim.loop.os_uname().sysname or "") == "Darwin"

local system_options_expr = string.format(
  [[
let
  flake = builtins.getFlake "%s";
  configs = flake.%s;
in
  if builtins.hasAttr "%s" configs
  then configs."%s".options
  else (builtins.head (builtins.attrValues configs)).options
]],
  flake_path,
  is_darwin and "darwinConfigurations" or "nixosConfigurations",
  hostname,
  hostname
)

local home_options_expr = string.format(
  [[
let
  flake = builtins.getFlake "%s";
  configs = flake.homeConfigurations;
  user_host = "%s@%s";
in
  if builtins.hasAttr user_host configs
  then configs.${user_host}.options
  else if builtins.hasAttr "%s" configs
  then configs."%s".options
  else (builtins.head (builtins.attrValues configs)).options
]],
  flake_path,
  username,
  hostname,
  username,
  username
)

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
              system = {
                expr = system_options_expr,
              },
              home_manager = {
                expr = home_options_expr,
              },
            },
          },
        },
      },
    },
  },
}
