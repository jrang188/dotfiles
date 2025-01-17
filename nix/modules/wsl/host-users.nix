{ hostname, username, ... }:
#############################################################
#
#  Host & Users configuration for NixOS
#
#############################################################
{
  networking = {
    hostName = hostname; # Sets the system's hostname
  };

  users.users.${username} = {
    isNormalUser = true;    # Mark this as a normal (non-system) user
    home = "/home/${username}"; # Default NixOS home directory
    description = username; # User description
    shell = pkgs.bashInteractive; # Default shell for the user
  };

  nix.settings.trusted-users = [ username ]; # Add the user to trusted users
}
