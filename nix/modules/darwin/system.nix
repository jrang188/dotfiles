{ pkgs, ... }:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#
###################################################################################
{
  system = {
    stateVersion = 5;
    # activationScripts are executed every time you boot the system or run `nixos-rebuild` / `darwin-rebuild`.
    activationScripts.UserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      # menuExtraClock.Show24Hour = true; # show 24 hour clock
      dock = {
        autohide = false;
        tilesize = 24;
        persistent-apps = [
          "System/Applications/Apps.app"
          "/Applications/Zen Browser.app"
          "${pkgs.ghostty-bin}/Applications/Ghostty.app"
          "/Applications/Warp.app"
          "/Applications/Cursor.app"
          "/Applications/Obsidian.app"
          "/Applications/Discord.app"
          "/Applications/Spotify.app"
          "/System/Applications/System Settings.app"
        ];
        wvous-br-corner = 1; # Avoid triggering quick note when hovering at bottom right corner
        show-recents = false;
      };
      NSGlobalDomain.KeyRepeat = 2;
    };
    primaryUser = "sirwayne";
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  fonts.packages = with pkgs; [ sketchybar-app-font ];
}
