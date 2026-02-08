_: {
  services = {
    howdy = {
      enable = true;
      settings = {
        video = {
          dark_threshold = 85;
        };
      };
      control = "sufficient";
    };
    linux-enable-ir-emitter.enable = true;
  };
  # Current fix for https://github.com/NixOS/nixpkgs/issues/483867
  systemd.services."polkit-agent-helper@".serviceConfig = {
    DeviceAllow = "char-video4linux rw";
    PrivateDevices = "no";
  };
}
