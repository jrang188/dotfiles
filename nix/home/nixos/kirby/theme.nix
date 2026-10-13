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

  # Qt dark theme - Adwaita platform theme to match the adw-gtk3 GTK theme
  #
  # NOTE: previously used the gtk2 platform theme (qtstyleplugins + qt6gtk2),
  # but pkgs.qt6Packages.qt6gtk2 was removed from nixpkgs 2026-07-22 because it
  # relied on gtk2 libraries. Adwaita is the maintained successor: the home-manager
  # qt module installs qadwaitadecorations(-qt6) for the platform theme and
  # adwaita-qt/adwaita-qt6 for the style automatically.
  qt = lib.mkIf cfg.enable {
    enable = true;
    platformTheme.name = "adwaita";
    style.name = "adwaita-dark";
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
    # Qt dark theme - Adwaita to match GTK theme.
    # Both QT_QPA_PLATFORMTHEME and QT_STYLE_OVERRIDE are set by the qt module
    # from platformTheme.name / style.name, so they are not set again here.
    # Electron apps dark mode
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";
  };

  # Additional packages for theming
  home.packages = lib.mkIf cfg.enable [
    pkgs.adw-gtk3
    pkgs.papirus-icon-theme
  ];
}
