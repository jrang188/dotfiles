{ pkgs, ... }:
{
  imports = [
    ../../modules/home/gui.nix
  ];
  
  home.packages = with pkgs; [
    # ============================================
    # macOS Audio Tools
    # ============================================
    switchaudio-osx  # macOS audio switcher
    nowplaying-cli   # Now playing CLI

    # ============================================
    # Mobile App Development
    # ============================================
    flutter          # Flutter SDK
    cocoapods        # CocoaPods dependency manager
  ];

  # Override ghostty package for Darwin (use ghostty-bin)
  programs.ghostty.package = pkgs.ghostty-bin;

  programs.zsh.oh-my-zsh.plugins = [ "macos" ];
}
