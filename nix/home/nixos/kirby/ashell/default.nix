_: {
  # ashell (replacing hyprpanel)
  programs.ashell = {
    enable = true;
    systemd.enable = true;
    settings = {
      # Modules
      modules = {
        left = [ [ "Workspaces" ] "Tray" ];
        center = [ "WindowTitle" ];
        right = [ "SystemInfo" "MediaPlayer" [ "Clock" "Privacy" "Settings" ] ];
      };
      workspaces = { visibility_mode = "MonitorSpecific"; };
      system_info = { indicators = [ "Cpu" "Memory" ]; };
      lock_cmd = "hyprlock &";
      remove_airplane_btn = true;
      vpn_more_cmd = "nm-connection-editor";
      indicators = [ "Audio" "Bluetooth" "Network" "Vpn" ];

      # Appearances
      # Notes: scale_factor doesn't seem to work
      font_name = "FiraCode Nerd Font Mono Ret";
      style = "solid";
    };
  };
}
