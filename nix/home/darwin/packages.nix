{ pkgs, ... }:
{
  home.packages = with pkgs; [
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
}
