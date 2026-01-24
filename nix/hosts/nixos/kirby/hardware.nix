{
  # Hardware configuration (non-generated)
  # Note: hardware-configuration.nix is auto-generated and should not be modified
  
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Experimental = true; # Show battery charge of Bluetooth devices
      };
    };
  };
}
