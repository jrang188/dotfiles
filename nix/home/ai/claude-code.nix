{ inputs, pkgs, ... }:

let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.claude-code = {
    enable = true;
    package = inputs.llm-agents.packages.${system}.claude-code;
    enableMcpIntegration = true;
  };
}
