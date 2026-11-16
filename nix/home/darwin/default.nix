{ pkgs, ... }:
{
  imports = [
    ../../modules/home/gui.nix
    ./aerospace.nix
    ./packages.nix
    ./gui.nix
    ./sketchybar.nix
  ];

  programs.zsh.oh-my-zsh.plugins = [ "macos" ];
}
