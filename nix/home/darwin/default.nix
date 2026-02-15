{ pkgs, ... }:
{
  imports = [
    ../../modules/home/gui.nix
    ./packages.nix
    ./gui.nix
  ];

  programs.zsh.oh-my-zsh.plugins = [ "macos" ];
}
