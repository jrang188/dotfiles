{
  pkgs,
  username,
  hostname,
  ...
}:
{
  imports = [
    ../../../modules/common
    ../../../modules/darwin
    ./homebrew.nix
  ];

  #############################################################
  #
  #  Host & Users configuration
  #
  #############################################################
  networking.hostName = hostname;
  networking.computerName = hostname;

  users.users.${username} = {
    home = "/Users/${username}";
    description = username;
  };

  nix.settings.trusted-users = [ username ];

  # Host-specific dock preferences
  system.defaults.dock.persistent-apps = [
    "System/Applications/Apps.app"
    "/Applications/Zen Browser.app"
    "${pkgs.ghostty-bin}/Applications/Ghostty.app"
    "/Applications/Zed.app"
    "/Applications/Cursor.app"
    "/Applications/Obsidian.app"
    "/Applications/Discord.app"
    "/Applications/Spotify.app"
    "/System/Applications/System Settings.app"
  ];
}
