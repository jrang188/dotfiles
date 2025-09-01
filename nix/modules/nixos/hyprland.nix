{ pkgs-unstable, ... }:
{
  programs.hyprland = {
    enable = true;
    package = pkgs-unstable.hyprland;
    xwayland.enable = true;
    portalPackage = pkgs-unstable.xdg-desktop-portal-hyprland;
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  environment.systemPackages = with pkgs-unstable; [
    hyprpanel # menu bar (too much hassle to rice waybar)
    rofi-wayland # app launcher
    hyprshot # screenshot tool
    hyprlock # lock screen for hyprland
    hypridle # idle management daeomon
    hyprpaper # wallpaper utility
    hyprpolkitagent # polkit agent
    hyprpicker # color pickers
    hyprsunset # blue-light filter during sunset

    # qt wayland library
    qt5.qtwayland
    qt6.qtwayland
  ];
}
