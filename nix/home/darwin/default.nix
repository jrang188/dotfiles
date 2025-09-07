{ pkgs-unstable, ... }:
{
  imports = [
    ../gui/ghostty.nix
  ];
  home.packages = with pkgs-unstable; [
    switchaudio-osx
    nowplaying-cli

    # Mobile App Dev
    flutter
    cocoapods
  ];

  programs.ghostty.package = pkgs-unstable.ghostty-bin;

  programs.zsh.oh-my-zsh.plugins = [
    "macos"
  ];
}
