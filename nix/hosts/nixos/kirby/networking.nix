{ pkgs, ... }:
{
  # Networking configuration
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-openvpn # openvpn manager
    ];
  };
}
