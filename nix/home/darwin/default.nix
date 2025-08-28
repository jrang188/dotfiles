{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    switchaudio-osx
    nowplaying-cli

    # Mobile App Dev
    flutter
    cocoapods
  ];

  programs.zsh.oh-my-zsh.plugins = [
    "macos"
  ];
}
