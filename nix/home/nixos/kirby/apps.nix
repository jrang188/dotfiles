{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    ghostty
    code-cursor
    vscode
    kitty
    jetbrains.idea-community-bin
    httpie
    warp-terminal

    xournalapp # PDF Editor
    spotify
    zoom-us
    libreoffice
    localsend
    obsidian
    notion-app
    chatgpt
    discord
    ticktick
  ];
}
