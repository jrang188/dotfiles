{ pkgs-unstable, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland;
    xwayland.enable = true;
    portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
  };
}
