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
      model = "opencode-go/mimo-v2-pro";
      plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
    };
    tui = {
      theme = "tokyonight";
    };
  };
}
