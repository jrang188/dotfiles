{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================
    # Wayland & System Tools
    # ============================================
    wl-clipboard     # Wayland clipboard utilities (wl-copy, wl-paste)

    # ============================================
    # System Utilities
    # ============================================
    chntpw           # Windows registry editor
    clang            # C/C++ compiler (macOS has clang by default, but needed on NixOS)
  ];
}
