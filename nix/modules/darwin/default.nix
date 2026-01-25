{ pkgs, pkgs-stable, ... }:
{
  imports = [
    ./apps.nix
    ./system.nix
  ];

  nix.optimise = {
    interval = {
      Weekday = 1;
      Hour = 2;
      Minute = 0;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
  };

  # Overlay to use stable pre-commit on Darwin to avoid dotnet dependency
  # See: https://github.com/NixOS/nixpkgs/issues/450554
  nixpkgs.overlays = [
    (final: prev: {
      inherit (pkgs-stable) pre-commit;
    })
  ];

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
}
