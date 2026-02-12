{ pkgs, ... }:
{
  imports = [
    ./packages.nix
    ./gui.nix
  ];

  programs.zsh.oh-my-zsh.plugins = [ "macos" ];
}
