_: {
  # ashell (replacing hyprpanel)
  # Only enable ashell when Hyprland is enabled
  programs.ashell = {
    enable = true;
    systemd = {
      enable = true;
      # graphical-session.target, not hyprland-session.target: the latter is
      # only started by wayland.windowManager.hyprland.systemd.enable, which
      # is false here (see the comment on that option in hyprland.nix) --
      # under uwsm, graphical-session.target is what actually comes up.
      target = "graphical-session.target";
    };
    settings = {
      # Modules
      modules = {
        left = [
          "Workspaces"
          "Tray"
        ];
        center = [ "WindowTitle" ];
        right = [
          "SystemInfo"
          "MediaPlayer"
          [
            "Clock"
            "Privacy"
            "Settings"
          ]
        ];
      };
      workspaces = {
        visibility_mode = "MonitorSpecific";
      };
      system_info = {
        indicators = [
          "Cpu"
          "Memory"
        ];
      };
      settings = {
        lock_cmd = "hyprlock &";
        remove_airplane_btn = true;
        vpn_more_cmd = "nm-connection-editor";
        indicators = [
          "Audio"
          "Bluetooth"
          "Network"
          "Vpn"
        ];
      };

      # Appearances
      appearance = {
        font_name = "FiraCode Nerd Font Mono";
        scale_factor = 1.2;

        primary_color = "#7aa2f7";
        success_color = "#9ece6a";
        text_color = "#a9b1d6";

        workspace_colors = [
          "#7aa2f7"
          "#9ece6a"
        ];

        danger_color = {
          base = "#f7768e";
          weak = "#e0af68";
        };

        background_color = {
          base = "#1a1b26";
          weak = "#24273a";
          strong = "#414868";
        };

        secondary_color = {
          base = "#0c0d14";
        };
      };
    };
  };
}
