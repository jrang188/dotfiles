{
  username,
  hostname,
  pkgs,
  lib,
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

  # WSL Specific Configurations
  wsl = {
    enable = true;
    wslConf.automount.root = "/mnt";
    defaultUser = username;
    startMenuLaunchers = true;
  };

  users.defaultUserShell = pkgs.zsh;

  # WSL Utilities (e.g. allows opening web urls)
  environment.systemPackages = with pkgs; [
    wslu
    socat
  ];

  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc
    zlib
    openssl
  ];

  nix = {
    settings = {
      trusted-users = [ username ];
      auto-optimise-store = true;
      eval-cores = 0;
    };

    # Auto upgrade nix package and the daemon service.
    optimise.automatic = true; # May make rebuilds longer but less size
    gc = {
      automatic = true;
      options = lib.mkDefault "--delete-older-than 7d";
      dates = "Daily";
    };
  };

  system.stateVersion = "24.05"; # Did you read the comment?
}
