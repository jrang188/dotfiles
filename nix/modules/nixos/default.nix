{
  pkgs,
  lib,
  ...
}:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./hyprland.nix
    ./podman.nix
  ];

  # Auto upgrade nix package and the daemon service.
  nix.optimise.automatic = true;
  nix.settings.auto-optimise-store = true; # May make rebuilds longer but less size
  nix.gc = {
    automatic = true;
    options = lib.mkDefault "--delete-older-than 7d";
    dates = "Daily";
  };
  nix.settings.eval-cores = 0;
  users.defaultUserShell = pkgs.zsh;
}
