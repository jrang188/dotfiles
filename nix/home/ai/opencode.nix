{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
in
{
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.opencode;
    enableMcpIntegration = true;
    settings = {
      model = "opencode-go/mimo-v2.5";
      plugin = [
        "oh-my-opencode-slim"
      ];
      agent = {
        explore = {
          disable = true;
        };
        general = {
          disable = true;
        };
      };
      lsp = true;
    };
    tui = {
      theme = "tokyonight";
    };
  };
}
