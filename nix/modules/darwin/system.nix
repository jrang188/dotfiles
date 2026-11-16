{ pkgs, username, ... }:
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
    primaryUser = username;

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
        wvous-br-corner = 1; # Avoid triggering quick note when hovering at bottom right corner
        show-recents = false;
      };
      NSGlobalDomain.KeyRepeat = 2;
    };
  };

  fonts.packages = with pkgs; [ sketchybar-app-font ];

  # launchd appends sketchybar's stdout/stderr forever and nothing rotates them by
  # default, so the files grew to 8 MB / 1 MB within months. macOS reads
  # /etc/newsyslog.d/*.conf (newsyslog.conf(5)) and the periodic
  # com.apple.newsyslog job runs it. Rotate on size only, keep 3 compressed
  # generations, and pass `N` because the writing process (launchd) must not be
  # signalled — it holds the file open in append mode.
  environment.etc."newsyslog.d/sketchybar.conf".text = ''
    # logfilename                                                    mode count size when flags
    /Users/${username}/Library/Logs/sketchybar/sketchybar.out.log     644  3     1024 *    JN
    /Users/${username}/Library/Logs/sketchybar/sketchybar.err.log     644  3     1024 *    JN
  '';
}
