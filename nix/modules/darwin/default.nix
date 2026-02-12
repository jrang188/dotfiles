{ pkgs, pkgs-stable, ... }:
{
  imports = [
    ./system.nix
    ./security.nix
  ];

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

  nix = {
    package = pkgs.nix;
    optimise = {
      interval = {
        Weekday = 1;
        Hour = 2;
        Minute = 0;
      };
    };
  };
}
