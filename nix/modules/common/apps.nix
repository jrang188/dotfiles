{ pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    git
    btop
    fastfetch
    ffmpeg
    wget
    curl
    zip
    unzip
  ];
}
