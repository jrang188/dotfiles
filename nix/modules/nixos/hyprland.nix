{ pkgs, inputs, ... }:
let
  # Hyprland 0.56.0 needs hyprutils >= 0.13.1, but nixpkgs-unstable still ships
  # 0.12.0 (lags behind upstream). Override nixpkgs' hyprutils with the pinned
  # upstream flake input so any nixpkgs-built consumers (e.g.
  # xdg-desktop-portal-hyprland) link against the same version the hyprland
  # flake uses. Drop the override once nixpkgs catches up to 0.13.1+.
  hyprutils = inputs.hyprutils.packages.${pkgs.stdenv.hostPlatform.system}.hyprutils;
in
{
  nixpkgs.overlays = [
    (_final: _prev: {
      inherit hyprutils;
    })
  ];

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    xwayland.enable = true;
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    withUWSM = true;
  };
}
