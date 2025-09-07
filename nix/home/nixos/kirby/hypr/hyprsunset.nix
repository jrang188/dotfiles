{ pkgs-unstable, ... }:
{
  services.hyprsunset = {
    enable = true;
    package = pkgs-unstable.hyprsunset;
    transitions = {
      sunrise = {
        calendar = "*-*-* 06:00:00";
        requests = [
          [
            "temperature"
            "5000"
          ]
          [ "gamma 100" ]
        ];
      };
      sunset = {
        calendar = "*-*-* 18:00:00";
        requests = [
          [
            "temperature"
            "4500"
          ]
          [ "gamma 1.2" ]
        ];
      };
    };
  };
}
