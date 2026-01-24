{ pkgs, ... }:
{
  imports = [
    ../../modules/home/gui.nix
  ];
  
  home.packages = with pkgs; [
    switchaudio-osx
    nowplaying-cli

    # Mobile App Dev
    flutter
    cocoapods
  ];

  # Override ghostty package for Darwin (use ghostty-bin)
  programs.ghostty.package = pkgs.ghostty-bin;

  programs.zsh.oh-my-zsh.plugins = [ "macos" ];
}
