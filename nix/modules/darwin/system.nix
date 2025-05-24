{ pkgs-unstable, ... }:
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
    activationScripts.postUserActivation.text = ''
      # activateSettings -u will reload the settings from the database and apply them to the current session,
      # so we do not need to logout and login again to make the changes take effect.
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';

    defaults = {
      # menuExtraClock.Show24Hour = true; # show 24 hour clock
      dock = {
        autohide = true;
        autohide-delay = 0.0;
        tilesize = 48;
        persistent-apps = [
          "System/Applications/Launchpad.app"
          "/Applications/Zen Browser.app"
          "/Applications/Warp.app"
          "/Applications/Cursor.app"
          "/Applications/Obsidian.app"
          "/Applications/TickTick.app"
          "/Applications/Discord.app"
          "/Applications/Spotify.app"
          "/System/Applications/System Settings.app"
        ];
        wvous-br-corner = 1; # Avoid triggering quick note when hovering at bottom right corner
        show-recents = false;
      };
      NSGlobalDomain.KeyRepeat = 2;
    };
  };

  # Add ability to used TouchID for sudo authentication
  security.pam.enableSudoTouchIdAuth = true;

  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;

  fonts.packages = with pkgs-unstable; [ sketchybar-app-font ];
}
