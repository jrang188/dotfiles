{ pkgs-unstable, ... }:
{
  programs.hyprlock = {
    enable = true;
    package = pkgs-unstable.hyprlock;
    settings = {
      background = {
        monitor = "";
        path = "/home/sirwayne/Pictures/wallpaper.jpg";
        color = "rgba(25, 20, 20, 1.0)";
        blur_passes = 2;
      };

      label = [
        {
          monitor = "";
          text = "cmd[update:1000] echo \"<b>$(date +'%H:%M:%S')</b>\"";
          color = "rgb(143, 143, 143)";
          font_size = 64;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = "cmd[update:1000] echo \"$(date +'%A, %B %d, %Y')\"";
          color = "rgb(143, 143, 143)";
          font_size = 24;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, -120";
          halign = "center";
          valign = "center";
        }
      ];

      input-field = {
        monitor = "";
        size = "20%, 5%";
        outline_thickness = 3;
        inner_color = "rgba(0, 0, 0, 0.0)"; # no fill

        outer_color = "rgba(33ccffee) rgba(00ff99ee) 45deg";
        check_color = "rgba(00ff99ee) rgba(ff6633ee) 120deg";
        fail_color = "rgba(ff6633ee) rgba(ff0066ee) 40deg";

        font_color = "rgb(143, 143, 143)";
        fade_on_empty = false;
        rounding = 15;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };
    };
  };
}
