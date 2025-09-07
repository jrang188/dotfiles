{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    code-cursor
    vscode
    kitty
    jetbrains.idea-community-bin
    httpie
    warp-terminal

    xournalpp # PDF Editor
    spotify
    zoom-us
    libreoffice
    localsend
    obsidian
    notion-app-enhanced
    discord-ptb
    ticktick
    webcord
    vesktop
  ];

  programs.ghostty.package = pkgs-unstable.ghostty;
}
