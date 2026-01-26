{ config, ... }:
{
  # KDE Plasma autostart applications
  # Only enable when Hyprland is NOT enabled (i.e., when using KDE)
  xdg.configFile."autostart/1password.desktop" = {
    enable = !(config.wayland.windowManager.hyprland.enable or false);
    text = ''
      [Desktop Entry]
      Type=Application
      Name=1Password
      Exec=1password --silent
      Icon=1password
      Terminal=false
      Categories=Utility;Security;
      X-GNOME-Autostart-enabled=true
    '';
  };
}
