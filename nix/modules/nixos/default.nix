{ pkgs-unstable, lib, ... }:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./nix-gc.nix
    ./hyprland.nix
  ];

  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = true; # May make rebuilds longer but less size
  nix.gc = {
    automatic = true;
    options = lib.mkDefault "--delete-older-than 7d";
    dates = "Daily";
  };
  users.defaultUserShell = pkgs-unstable.zsh;
}
