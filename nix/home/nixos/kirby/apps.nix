{ pkgs, pkgs-stable, ... }:
{
  home.packages =
    with pkgs;
    [
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
      # webcord # electron-36.9.5 EOL error
      # vesktop
      podman-desktop
      prismlauncher
    ]
    ++ [ pkgs-stable.vesktop ];

  programs.ghostty.package = pkgs.ghostty;
}
