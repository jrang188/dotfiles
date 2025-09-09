{ pkgs-unstable, ... }:
{
  services.hyprpaper = {
    enable = true;
    package = pkgs-unstable.hyprpaper;
    settings = {
      preload = "~/dotfiles/wallpapers/spiderverse.jpg";
      wallpaper = ", ~/dotfiles/wallpapers/spiderverse.jpg";
    };
  };
}
