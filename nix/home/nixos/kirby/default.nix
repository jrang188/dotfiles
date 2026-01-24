{ ... }:
{
  imports = [
    ./apps.nix
    ./packages.nix
    ./zen-browser.nix
    ./hyprland.nix
    ./rofi.nix
    ../../gui
    ./ashell.nix
  ];
}
