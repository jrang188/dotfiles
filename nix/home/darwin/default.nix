{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    switchaudio-osx
  ];

  programs.zsh.oh-my-zsh.plugins = [
    "macos"
  ];
}
