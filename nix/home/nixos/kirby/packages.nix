{ pkgs-unstable, ... }:
{
  home.packages = with pkgs-unstable; [
    wl-clipboard # Implements wl-copy and wl-paste
  ];
}
