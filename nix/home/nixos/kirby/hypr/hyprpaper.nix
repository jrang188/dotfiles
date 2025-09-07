{ pkgs-unstable, ... }:
{
  programs.hyprpaper = {
    enable = true;
    package = pkgs-unstable.hyprpaper;
    settings = {
      preload = "../../../../wallpapers/spiderverse.jpg";
      wallpaper = ", ../../../../wallpapers/spiderverse.jpg";
    };
  };
}
