{ pkgs, ... }:
{
  imports = [
    ../gui/ghostty.nix
  ];
  home.packages = with pkgs; [
    switchaudio-osx
    nowplaying-cli

    # Mobile App Dev
    flutter
    cocoapods
  ];

  programs.ghostty.package = pkgs.ghostty-bin;

  programs.zsh.oh-my-zsh.plugins = [
    "macos"
  ];
}
