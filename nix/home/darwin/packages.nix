{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================
    # GUI Applications
    # ============================================
    ghostty-bin # Terminal emulator (needs to be in packages for mac-app-util trampolining)
    syncthing-macos # Syncthing GUI

    # ============================================
    # macOS Audio Tools
    # ============================================
    switchaudio-osx # macOS audio switcher
    nowplaying-cli # Now playing CLI

    # ============================================
    # macOS Window Management
    # ============================================
    # JankyBorders: the window border AeroSpace launches at startup via
    # `exec-and-forget borders …`. Version 1.9.0 matches the Homebrew formula it
    # replaced, so the CLI is identical. AeroSpace's exec PATH puts
    # /etc/profiles/per-user/$USER/bin first, so the bare `borders` in
    # `after-startup-command` resolves to this one.
    jankyborders

    # ============================================
    # Mobile App Development
    # ============================================
    # flutter # Flutter SDK
    # cocoapods # CocoaPods dependency manager
    # android-tools

    # ============================================
    # AirSync Dependency
    # ============================================
    # scrcpy
  ];

  programs.neovim.extraPackages = with pkgs; [ pngpaste ];

}
