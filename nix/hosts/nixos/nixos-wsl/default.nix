{
  username,
  hostname,
  pkgs,
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

  # Needed for VScode in WSL (Workaround)
  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs; # only for NixOS 24.05
  };

  # Set default shell TODO: Refactor this into the nixos module
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Enable autoupgrade
  system.autoUpgrade = {
    enable = true;
    flake = "/home/${username}/dotfiles/nix";
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "23:00";
    randomizedDelaySec = "45min";
    persistent = true;
  };

  # WSL Utilities (e.g. allows opening web urls)
  environment.systemPackages = with pkgs; [
    wslu
  ];

  system.stateVersion = "24.05"; # Did you read the comment?
}
