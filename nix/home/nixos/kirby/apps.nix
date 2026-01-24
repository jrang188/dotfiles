{ pkgs, ... }:
{
  home.packages = with pkgs; [
    code-cursor
    vscode
    kitty
    httpie
    warp-terminal
    microsoft-edge
    xournalpp # PDF Editor
    spotify
    zoom-us
    libreoffice
    obsidian
    notion-app-enhanced
    discord
    ticktick
    webcord
    vesktop
    podman-desktop
    prismlauncher
    blueman
  ];
}
