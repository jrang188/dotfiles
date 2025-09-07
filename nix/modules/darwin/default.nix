{ ... }:
{
  imports = [
    ./apps.nix
    ./system.nix
  ];

  nix.optimise = {
    automatic = true;
    interval = {
      Weekday = "1";
      Hour = "2";
      Minute = "0";
    };
  };
}
