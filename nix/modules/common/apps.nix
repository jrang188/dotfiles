{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    btop
    fastfetch
    ffmpeg
    wget
    curl
  ];
}
