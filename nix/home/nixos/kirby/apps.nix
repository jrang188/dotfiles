{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    ghostty
    code-cursor
    vscode
  ];
}
