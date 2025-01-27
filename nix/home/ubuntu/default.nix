{ pkgs, ... }:
{
  programs.zsh.oh-my-zsh.plugins = [
    "ubuntu"
  ];

  home.packages = with pkgs; [
    git
    btop
    fastfetch
    ffmpeg
    wget
    curl
  ];

  nixpkgs.config.allowUnfree = true;
}
