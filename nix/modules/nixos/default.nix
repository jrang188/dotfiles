{ pkgs-unstable, ... }:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./nix-gc.nix
    ./hyprland.nix
  ];

  users.defaultUserShell = pkgs-unstable.zsh;
}
