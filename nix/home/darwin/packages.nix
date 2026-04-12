{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================
    # GUI Applications
    # ============================================
    ghostty-bin # Terminal emulator (needs to be in packages for mac-app-util trampolining)

    # ============================================
    # macOS Audio Tools
    # ============================================
    switchaudio-osx # macOS audio switcher
    nowplaying-cli # Now playing CLI

    # ============================================
    # Mobile App Development
    # ============================================
    flutter # Flutter SDK
    cocoapods # CocoaPods dependency manager
  ];

  programs.neovim.extraPackages = with pkgs; [ pngpaste ];

}
