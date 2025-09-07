{ pkgs-unstable, ... }:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./nix-gc.nix
    ./hyprland.nix
  ];

  nix.settings.auto-optimise-store = true; # May make rebuilds longer but less size
  users.defaultUserShell = pkgs-unstable.zsh;
}
