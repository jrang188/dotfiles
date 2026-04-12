{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.opencode = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.opencode;
    enableMcpIntegration = true;
    settings = {
      plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
    };
    tui = {
      theme = "tokyonight";
    };
  };
}
