{ pkgs, ... }:
{
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
  };

  environment.systemPackages = with pkgs; [
    openrgb-with-all-plugins
  ];
}
