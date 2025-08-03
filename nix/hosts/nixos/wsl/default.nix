{
  username,
  hostname,
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [ ../../../modules/common ];
  #############################################################
  #
  #  Host & Users configuration
  #
  #############################################################
  networking.hostName = hostname;

  users.users.${username} = {
    home = "/home/${username}";
    description = username;
  };

  nix.settings.trusted-users = [ username ];

  # WSL Specific Configurations
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = username;
    startMenuLaunchers = true;
  };

  users.defaultUserShell = pkgs.zsh;

  # WSL Utilities (e.g. allows opening web urls)
  environment.systemPackages = with pkgs-unstable; [
    wslu
    socat
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
