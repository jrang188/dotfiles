{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    package = pkgs.yazi;

    # Enable zsh integration
    enableZshIntegration = true;
  };
}
