{ ... }:
{
  imports = [
    ./flatpak.nix
    ./nix-ld.nix
    ./1password.nix
    ./hyprland.nix
    ./podman.nix
    ./localsend.nix
    ./user-shell.nix
  ];

  nix = {
    gc.dates = "Daily";
    optimise.automatic = true;
  };
}
