{ pkgs-unstable, ... }:
{
  programs.hyprpaper = {
    enable = true;
    package = pkgs-unstable.hyprpaper;
    settings = {
      preload = "/home/sirwayne/Pictures/wallpaper.jpg";
      wallpaper = ", /home/sirwayne/Pictures/wallpaper.jpg";
    };
  };
}
