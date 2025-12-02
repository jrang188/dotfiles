{ pkgs, ... }:
{
  home.packages = with pkgs; [
    wl-clipboard # Implements wl-copy and wl-paste
    chntpw
  ];
}
