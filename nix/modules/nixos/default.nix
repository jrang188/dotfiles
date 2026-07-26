{ pkgs, lib, ... }:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./hyprland.nix
    ./podman.nix
    ./localsend.nix
  ];
  nix = {
    package = pkgs.lixPackageSets.stable.lix;

    # Auto upgrade nix package and the daemon service.
    optimise.automatic = true;
    settings.auto-optimise-store = true; # May make rebuilds longer but less size
    gc = {
      automatic = true;
      options = lib.mkDefault "--delete-older-than 7d";
      dates = "Daily";
    };
  };
  users.defaultUserShell = pkgs.zsh;
}
