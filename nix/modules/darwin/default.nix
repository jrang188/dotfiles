{ pkgs, ... }:
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

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
}
