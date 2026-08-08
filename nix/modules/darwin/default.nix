{ lib, ... }:
{
  imports = [
    ./system.nix
    ./security.nix
    ./insecure-packages.nix
  ];

  nix = {
    gc.interval = {
      Weekday = 0;
      Hour = 3;
      Minute = 0;
    };
    optimise.interval = {
      Weekday = 1;
      Hour = 2;
      Minute = 0;
    };
  };
}
