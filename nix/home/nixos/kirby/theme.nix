{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.wayland.windowManager.hyprland;
in
{
  # Tokyo Night Dark theme configuration for all GUI applications
  # Only enabled when using Hyprland

  # GTK dark theme - Tokyo Night
  gtk = lib.mkIf cfg.enable {
    enable = true;
    theme = {
      name = "Tokyonight-Dark";
      package = pkgs.tokyonight-gtk-theme;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
    gtk4 = {
      extraConfig.gtk-application-prefer-dark-theme = true;
      theme = null;
    };
  };

  # Qt dark theme - use gtk2 platform theme to match Tokyo Night GTK theme
  qt = lib.mkIf cfg.enable {
    enable = true;
    platformTheme.name = "gtk";
    style = {
      name = "gtk2";
      package = pkgs.qt6Packages.qt6gtk2;
    };
  };

  # Dark theme for xdg-desktop-portal
  xdg.configFile."xdg-desktop-portal/portals.conf" = lib.mkIf cfg.enable {
    text = ''
      [preferred]
      default=hyprland;gtk
    '';
  };

  # Environment variables for dark theme
  home.sessionVariables = lib.mkIf cfg.enable {
    # GTK dark theme - Tokyo Night
    GTK_THEME = "Tokyonight-Dark";
    # Qt dark theme - use gtk2 to match GTK theme
    QT_QPA_PLATFORMTHEME = "gtk2";
    QT_STYLE_OVERRIDE = "gtk2";
    # Electron apps dark mode
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Additional packages for theming
  home.packages = lib.mkIf cfg.enable [
    pkgs.tokyonight-gtk-theme
    pkgs.papirus-icon-theme
    pkgs.qt6Packages.qt6gtk2
    pkgs.libsForQt5.qt5ct
    pkgs.kdePackages.qt6ct
  ];
}
