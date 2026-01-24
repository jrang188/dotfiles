{ pkgs, ... }:
{
  services.hyprsunset = {
    enable = true;
    package = pkgs.hyprsunset;
    settings = {
      max-gamma = 150;

      profile = [
        {
          time = "7:00";
          identity = true;
        }
        {
          time = "18:00";
          temperature = 4500;
          gamma = 1.2;
        }
      ];
    };
  };
}
