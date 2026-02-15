{ pkgs, ... }:
{
  services.hardware.openrgb = {
    enable = true;
    motherboard = "amd";
    package = pkgs.openrgb-with-all-plugins;
  };
  hardware = {
    # Enable UniSync for OpenRGB (Control LianLi SL Fans)
    uni-sync = {
      enable = true;
      devices = [
        {
          device_id = "VID=3314/PID=41216/SN=6243168001/PATH=1-7.1=1.1";
          sync_rgb = true;
          channels = [
            {
              mode = "PWM";
            }
            {
              mode = "PWM";
            }
            {
              mode = "PWM";
            }
            {
              mode = "PWM";
            }
          ];
        }
      ];
    };
  };
}
