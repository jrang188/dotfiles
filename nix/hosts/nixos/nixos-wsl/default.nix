{
  username,
  hostname,
  pkgs,
  ...
}:
{
  imports = [
    ../../../modules/common
  ];
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

  # Needed for VScode in WSL (Workaround)
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

  # Set default shell TODO: Refactor this into the nixos module
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  system.stateVersion = "24.05"; # Did you read the comment?
}
