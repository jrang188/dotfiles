{ pkgs, ... }:
{
  imports = [
    ../../../modules/home/gui.nix
    ./apps.nix
    ./packages.nix
    ./zen-browser.nix
    ./hyprland.nix
    ./rofi.nix
    ./ashell.nix
  ];

  # Override ghostty package for NixOS (use regular ghostty)
  programs.ghostty.package = pkgs.ghostty;
}
