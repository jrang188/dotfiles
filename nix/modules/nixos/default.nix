{ pkgs-unstable, ... }:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./nix-gc.nix
    ./hyprland.nix
  ];
  nix.optimise.automatic = true;
  users.defaultUserShell = pkgs-unstable.zsh;
}
