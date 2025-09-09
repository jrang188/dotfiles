{
  pkgs-unstable,
  ...
}:
{
  imports = [
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./hyprsunset.nix
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    settings = {

      # Set programs that you use
      "$terminal" = "ghostty";
      "$fileManager" = "dolphin";
      "$menu" = "rofi -show drun -show-icons";
      "$browser" = "zen";
      "$1pass" = "1password";

      # Autostart
      "exec-once" = [
        "hyprpanel"
        "systemctl --user start hyprpolkitagent"
        "1password --silent" # 1password in the background
      ];

      "monitor" = [
        ",preferred,auto,auto"
        "dp-2,2560x1440@144.01hz,auto,auto"

        # when you want to use hdr mode
        # "dp-2,2560x1440@144.01hz,auto,auto,bitdepth,10,cm,hdr,sdrbrightness,1.5"
      ];

      # Look and Feel
      "general" = {
        "gaps_in" = 4;
        "gaps_out" = 9;
        "border_size" = 2;
        "col.active_border" = "rgba(ca9ee6ff) rgba(f2d5cfff) 45deg";
        "col.inactive_border" = "rgba(b4befecc) rgba(6c7086cc) 45deg";
        "resize_on_border" = true;
        "allow_tearing" = false;
        "layout" = "dwindle";
      };
      "decoration" = {
        "rounding" = 10;
        "rounding_power" = 2;
        "active_opacity" = 1.0;
        "inactive_opacity" = 0.85;
        "blur" = {
          "enabled" = true;
          "special" = true;
          "size" = 6;
          "passes" = 2;
          "vibrancy" = 0.1696;
        };
      };
      "animations" = {
        "enabled" = true;
        "bezier" = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        "animation" = [
          "global, 1, 10, default"
          "border, 1, 5.39, easeOutQuint"
          "windows, 1, 4.79, easeOutQuint"
          "windowsIn, 1, 4.1, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.49, linear, popin 87%"
          "fadeIn, 1, 1.73, almostLinear"
          "fadeOut, 1, 1.46, almostLinear"
          "fade, 1, 3.03, quick"
          "layers, 1, 3.81, easeOutQuint"
          "layersIn, 1, 4, easeOutQuint, fade"
          "layersOut, 1, 1.5, linear, fade"
          "fadeLayersIn, 1, 1.79, almostLinear"
          "fadeLayersOut, 1, 1.39, almostLinear"
          "workspaces, 1, 1.94, almostLinear, fade"
          "workspacesIn, 1, 1.21, almostLinear, fade"
          "workspacesOut, 1, 1.94, almostLinear, fade"
        ];
      };
      "dwindle" = {
        "pseudotile" = true;
        "preserve_split" = true;
      };
      "master" = {
        "new_status" = "master";
      };
      "misc" = {
        "force_default_wallpaper" = -1;
        "disable_hyprland_logo" = true;
      };

      # Input
      "input" = {
        "kb_layout" = "us";
        "kb_variant" = "";
        "kb_model" = "";
        "kb_options" = "";
        "kb_rules" = "";
        "follow_mouse" = 1;
        "sensitivity" = 1.0;
      };

      # Keybindings
      "$mainMod" = "ALT"; # Main modifier key (Alt instead of Super)
      "$superShift" = "SUPER SHIFT"; # Super + Shift combination

      "bind" = [
        # Basic application shortcuts
        "$mainMod, T, exec, $terminal" # Open terminal
        "$mainMod, C, killactive" # Close active window
        "$mainMod, M, exit" # Exit Hyprland
        "$mainMod, V, togglefloating" # Toggle floating mode
        "$mainMod, space, exec, $menu" # Open application menu
        "$mainMod, P, pseudo" # Toggle pseudotiling (dwindle layout)
        "$mainMod, backslash, togglesplit" # Toggle split direction (dwindle layout)
        "$mainMod, B, exec, $browser" # Open browser
        "$superShift, 1, exec, $1pass" # Open 1Password

        # Screenshot shortcuts
        "$superShift, w, exec, hyprshot -m window" # Screenshot window
        "$superShift, f, exec, hyprshot -m active -m output" # Screenshot fullscreen
        "$superShift, r, exec, hyprshot -m region" # Screenshot region

        # System shortcuts
        "$superShift, l, exec, hyprlock" # Lock screen

        # Window focus (vim-like navigation)
        "$mainMod, h, movefocus, l" # Focus left
        "$mainMod, j, movefocus, r" # Focus right
        "$mainMod, k, movefocus, u" # Focus up
        "$mainMod, l, movefocus, d" # Focus down

        # Workspace switching (1-10)
        "$mainMod, 1, workspace, 1"
        "$mainMod, 2, workspace, 2"
        "$mainMod, 3, workspace, 3"
        "$mainMod, 4, workspace, 4"
        "$mainMod, 5, workspace, 5"
        "$mainMod, 6, workspace, 6"
        "$mainMod, 7, workspace, 7"
        "$mainMod, 8, workspace, 8"
        "$mainMod, 9, workspace, 9"
        "$mainMod, 0, workspace, 10"

        # Move window to workspace (Alt + Shift + number)
        "$mainMod SHIFT, 1, movetoworkspace, 1"
        "$mainMod SHIFT, 2, movetoworkspace, 2"
        "$mainMod SHIFT, 3, movetoworkspace, 3"
        "$mainMod SHIFT, 4, movetoworkspace, 4"
        "$mainMod SHIFT, 5, movetoworkspace, 5"
        "$mainMod SHIFT, 6, movetoworkspace, 6"
        "$mainMod SHIFT, 7, movetoworkspace, 7"
        "$mainMod SHIFT, 8, movetoworkspace, 8"
        "$mainMod SHIFT, 9, movetoworkspace, 9"
        "$mainMod SHIFT, 0, movetoworkspace, 10"

        # Special workspace (scratchpad)
        "$mainMod, S, togglespecialworkspace, magic" # Toggle magic workspace
        "$mainMod SHIFT, S, movetoworkspace, special:magic" # Move to magic workspace

        # Mouse workspace navigation
        "$mainMod, mouse_down, workspace, e+1" # Scroll to next workspace
        "$mainMod, mouse_up, workspace, e-1" # Scroll to previous workspace
      ];

      # Multimedia keys (repeatable - bindel)
      "bindel" = [
        ",XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+" # Volume up
        ",XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-" # Volume down
        ",XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" # Mute/unmute
        ",XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" # Mic mute/unmute
        ",XF86MonBrightnessUp, exec, brightnessctl -e4 -n2 set 5%+" # Brightness up
        ",XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-" # Brightness down
      ];

      # Media control keys (lockable - bindl)
      "bindl" = [
        ", XF86AudioNext, exec, playerctl next" # Next track
        ", XF86AudioPause, exec, playerctl play-pause" # Play/pause
        ", XF86AudioPlay, exec, playerctl play-pause" # Play/pause (alternative)
        ", XF86AudioPrev, exec, playerctl previous" # Previous track
      ];

      # Mouse bindings (bindm)
      "bindm" = [
        "$mainMod, mouse:272, movewindow" # Alt + Left click + drag = move window
        "$mainMod, mouse:273, resizewindow" # Alt + Right click + drag = resize window
      ];

      # Window Rules
      "windowrule" = [
        "suppressevent maximize, class:.*" # Prevent apps from auto-maximizing
        "nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0" # Fix XWayland focus issues
      ];
    };

    plugins = [ pkgs-unstable.hyprlandPlugins.hy3 ];
  };

  home.packages = with pkgs-unstable; [
    hyprshot # screenshot tool
    hyprpolkitagent # polkit agent
    hyprpicker # color picker
    hyprpanel # menu bar (too much hassle to rice waybar)
    rofi-wayland # temporary since i want to try walker

    # qt wayland library
    qt5.qtwayland
    qt6.qtwayland
  ];

  home.sessionVariables.NIXOS_OZONE_WL = "1";
}
