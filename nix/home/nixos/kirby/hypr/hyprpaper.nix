{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    package = pkgs.hyprpaper;
    settings = {
      preload = "~/dotfiles/wallpapers/spiderverse.jpg";
      wallpaper = ", ~/dotfiles/wallpapers/spiderverse.jpg";
    };
  };
}
