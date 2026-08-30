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
  # Dark theme configuration for all GUI applications
  # Only enabled when using Hyprland
  #
  # NOTE: previously used pkgs.tokyonight-gtk-theme, but it (and every other
  # murrine-based GTK theme) was removed from nixpkgs 2026-07-22 because it
  # depended on gtk-engine-murrine, which was removed for being unmaintained
  # and GTK2-only. adw-gtk3 is the actively-maintained replacement (a GTK3
  # port of libadwaita, no murrine dependency); Tokyo Night accent colors
  # still come through via the Hyprland border/decoration colors.

  # GTK dark theme
  gtk = lib.mkIf cfg.enable {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
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

  # Qt dark theme - use gtk2 platform theme to match the GTK theme
  qt = lib.mkIf cfg.enable {
    enable = true;
    platformTheme.name = "gtk2";
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
    # GTK dark theme
    GTK_THEME = "adw-gtk3-dark";
    # Qt dark theme - use gtk2 to match GTK theme
    # QT_QPA_PLATFORMTHEME is managed by the qt module via platformTheme.name
    QT_STYLE_OVERRIDE = "gtk2";
    # Electron apps dark mode
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Additional packages for theming
  home.packages = lib.mkIf cfg.enable [
    pkgs.adw-gtk3
    pkgs.papirus-icon-theme
    pkgs.qt6Packages.qt6gtk2
    pkgs.libsForQt5.qt5ct
    pkgs.kdePackages.qt6ct
  ];
}
