{ lib, ... }:
let
  inherit (lib)
    concatLists
    filter
    listToAttrs
    mapAttrsToList
    nameValuePair
    ;

  # Single source of truth for workspaces. `key` drives the alt-<key> /
  # alt-shift-<key> bindings; `monitor` (named workspaces only) drives
  # workspace-to-monitor-force-assignment. Adding a workspace is one line here.
  workspaces = [
    {
      name = "1";
      key = "1";
    }
    {
      name = "2";
      key = "2";
    }
    {
      name = "3";
      key = "3";
    }
    {
      name = "4";
      key = "4";
    }
    {
      name = "5";
      key = "5";
    }
    {
      name = "6";
      key = "6";
    }
    {
      name = "7";
      key = "7";
    }
    {
      name = "8";
      key = "8";
    }
    {
      name = "9";
      key = "9";
    }
    {
      name = "Comms";
      key = "c";
      monitor = "secondary";
    }
    {
      name = "Web";
      key = "w";
      monitor = "primary";
    }
    {
      name = "Dev";
      key = "d";
      monitor = "primary";
    }
    {
      name = "Note";
      key = "n";
      monitor = "secondary";
    }
    {
      name = "Media";
      key = "m";
      monitor = "secondary";
    }
    {
      name = "Shell";
      key = "s";
      monitor = "primary";
    }
    {
      name = "Utility";
      key = "u";
      monitor = "secondary";
    }
  ];

  # app-bundle-id -> workspace; generates the on-window-detected rules.
  appRules = {
    Utility = [ "com.nordvpn.NordVPN" ];
    Comms = [
      "com.tinyspeck.slackmacgap"
      "com.hnc.Discord"
      "com.facebook.archon.developerID"
      "us.zoom.xos"
      "com.apple.FaceTime"
      "com.apple.mail"
      "com.apple.MobileSMS"
      "com.microsoft.Outlook"
    ];
    Note = [
      "com.anytype.anytype"
      "io.capacities.app"
      "notion.id"
      "md.obsidian"
      "com.apple.Notes"
      "com.apple.Stickies"
      "com.electron.logseq"
    ];
    Media = [ "com.spotify.client" ];
  };

  # The four places each workspace used to be repeated, now derived.
  workspaceBindings = listToAttrs (
    map (w: nameValuePair "alt-${w.key}" "workspace ${w.name}") workspaces
  );
  moveBindings = listToAttrs (
    map (w: nameValuePair "alt-shift-${w.key}" "move-node-to-workspace ${w.name}") workspaces
  );
  monitorAssignment = listToAttrs (
    map (w: nameValuePair w.name w.monitor) (filter (w: w ? monitor) workspaces)
  );
  windowRules = concatLists (
    mapAttrsToList (
      ws: ids:
      map (id: {
        "if" = "test %{app-bundle-id} = ${id}";
        run = "move-node-to-workspace ${ws}";
      }) ids
    ) appRules
  );
in
{
  # Programs that run after login are handled by the launchd agent below rather
  # than AeroSpace itself (the module asserts on start-at-login/after-login-command
  # and rewrites both in the generated file).
  programs.aerospace = {
    enable = true;
    launchd.enable = true;

    settings = {
      config-version = 2;

      # Borders detects an already-running process, so a restart won't double it.
      after-startup-command = [
        "exec-and-forget borders active_color=0xffc0caf5 inactive_color=0xff414868 style=round width=7.0"
        "exec-and-forget sketchybar"
      ];

      exec-on-workspace-change = [
        "/bin/bash"
        "-c"
        ''sketchybar --trigger aerospace_workspace_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE FOCUSED_DISPLAY=$(aerospace list-monitors --focused | awk "{print $1}")''
      ];

      on-focus-changed = [
        "exec-and-forget sketchybar --trigger aerospace_focus_change FOCUSED_WORKSPACE=$AEROSPACE_FOCUSED_WORKSPACE"
      ];

      persistent-workspaces = map (w: w.name) workspaces;

      enable-normalization-flatten-containers = true;
      enable-normalization-opposite-orientation-for-nested-containers = true;

      accordion-padding = 30;
      default-root-container-layout = "tiles";
      default-root-container-orientation = "auto";

      on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
      automatically-unhide-macos-hidden-apps = false;

      key-mapping.preset = "qwerty";

      gaps = {
        inner = {
          horizontal = 10;
          vertical = 10;
        };
        outer = {
          left = 10;
          right = 10;
          top = [
            { monitor.built-in = 20; }
            50
          ];
          bottom = [
            { monitor.built-in = 10; }
            10
          ];
        };
      };

      mode = {
        main.binding = {
          alt-slash = "layout tiles horizontal vertical";
          alt-comma = "layout accordion horizontal vertical";

          alt-h = "focus left";
          alt-j = "focus down";
          alt-k = "focus up";
          alt-l = "focus right";

          alt-shift-h = "move left";
          alt-shift-j = "move down";
          alt-shift-k = "move up";
          alt-shift-l = "move right";

          alt-minus = "resize smart -50";
          alt-equal = "resize smart +50";

          alt-tab = "workspace-back-and-forth";
          alt-shift-tab = "move-workspace-to-monitor --wrap-around next";

          alt-shift-semicolon = [
            "mode service"
            "exec-and-forget sketchybar --trigger aerospace_enter_service_mode"
          ];

          alt-f = "fullscreen";
        }
        // workspaceBindings
        // moveBindings;

        service.binding = {
          esc = [
            "reload-config"
            "mode main"
            "exec-and-forget sketchybar --trigger aerospace_leave_service_mode"
          ];

          # reset layout
          r = [
            "flatten-workspace-tree"
            "mode main"
          ];

          # toggle between floating and tiling layout
          f = [
            "layout floating tiling"
            "mode main"
            "exec-and-forget sketchybar --trigger aerospace_leave_service_mode"
          ];

          backspace = [
            "close-all-windows-but-current"
            "mode main"
            "exec-and-forget sketchybar --trigger aerospace_leave_service_mode"
          ];

          alt-shift-h = [
            "join-with left"
            "mode main"
          ];
          alt-shift-j = [
            "join-with down"
            "mode main"
          ];
          alt-shift-k = [
            "join-with up"
            "mode main"
          ];
          alt-shift-l = [
            "join-with right"
            "mode main"
          ];

          down = "volume down";
          up = "volume up";
          shift-down = [
            "volume set 0"
            "mode main"
          ];
        };
      };

      workspace-to-monitor-force-assignment = monitorAssignment;

      on-window-detected = windowRules;
    };
  };
}
