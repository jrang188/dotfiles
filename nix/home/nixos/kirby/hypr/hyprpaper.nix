{ pkgs, ... }:
{
  services.hyprpaper = {
    enable = true;
    package = pkgs.hyprpaper;
    settings = {
      wallpaper = [
        {
          "monitor" = "DP-2";
          "path" = "~/dotfiles/wallpapers/spiderverse.jpg";
        }
      ];
    };
  };
}
