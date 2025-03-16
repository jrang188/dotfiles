{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    switchaudio-osx
    nowplaying-cli
  ];

  programs.zsh.oh-my-zsh.plugins = [
    "macos"
  ];
}
