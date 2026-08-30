{ pkgs, lib, ... }:
{
  # Hyprland window manager configuration
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;

    # Migrated off hyprlang (2026-08-30): hyprlang is deprecated as of
    # Hyprland 0.55 and slated for removal in 0.57/0.58. `settings` below
    # uses the lua-config.nix schema documented at
    # https://github.com/nix-community/home-manager (tests/modules/services/hyprland),
    # not the old hyprlang attrset shape -- top-level keys map 1:1 to `hl.<key>(...)`
    # calls, and dispatcher calls / lua-local references must be wrapped in
    # `lib.generators.mkLuaInline` so they render as code, not string literals.
    # Dispatcher reference: https://wiki.hypr.land/Configuring/Basics/Dispatchers/
    configType = "lua";

    # MUST stay false while the session is launched through uwsm
    # (`programs.hyprland.withUWSM = true` in modules/nixos/hyprland.nix).
    #
    # When true (the home-manager default), the module injects
    #   exec-once = ... && systemctl --user stop hyprland-session.target \
    #                   && systemctl --user start hyprland-session.target
    # into hyprland.conf. `hyprland-session.target` has
    # PropagatesStopTo=graphical-session.target, and under uwsm the compositor
    # unit is chained to it (wayland-session@hyprland.desktop.target
    # BindsTo=graphical-session.target, wayland-wm@hyprland.desktop.service
    # BindsTo=wayland-session@...). So that momentary `stop` propagates back
    # into the compositor's own unit and SIGTERMs Hyprland ~1s after a fully
    # successful start. Hyprland shuts down cleanly, systemd sees OnSuccess=
    # (exit 0, no crash, no coredump) and SDDM just returns to the greeter --
    # which is why this looked like a login loop with no error anywhere.
    # Upstream: hyprwm/Hyprland#15688.
    #
    # uwsm brings up graphical-session.target itself, so nothing is lost here.
    # Trade-off: the plain (non-uwsm) `hyprland.desktop` session no longer
    # starts graphical-session.target, so hypridle/hyprpaper/hyprsunset/swaync
    # won't autostart there. Log in via "Hyprland (uwsm-managed)".
    systemd.enable = false;

    settings = {
      monitor = [
        {
          output = "";
          mode = "preferred";
          position = "auto";
          scale = "auto";
        }
        {
          output = "dp-2";
          mode = "2560x1440@144.01hz";
          position = "auto";
          scale = "auto";
        }

        # when you want to use hdr mode
        # { output = "dp-2"; mode = "2560x1440@144.01hz"; position = "auto"; scale = "auto"; bitdepth = 10; cm = "hdr"; sdrbrightness = 1.5; }
      ];

      # Look and Feel
      config = {
        general = {
          gaps_in = 4;
          gaps_out = 9;
          border_size = 2;
          col = {
            active_border = {
              colors = [
                "rgba(7aa2f7ff)"
                "rgba(bb9af7ff)"
              ];
              angle = 45;
            };
            inactive_border = {
              colors = [
                "rgba(565f89cc)"
                "rgba(414868cc)"
              ];
              angle = 45;
            };
          };
          resize_on_border = true;
          allow_tearing = false;
          layout = "dwindle";
        };
        decoration = {
          rounding = 10;
          rounding_power = 2;
          active_opacity = 1.0;
          inactive_opacity = 0.85;
          blur = {
            enabled = true;
            special = true;
            size = 6;
            passes = 2;
            vibrancy = 0.1696;
          };
        };
        animations = {
          enabled = true;
        };
        dwindle = {
          preserve_split = true;
        };
        misc = {
          force_default_wallpaper = -1;
          disable_hyprland_logo = true;
        };
        input = {
          kb_layout = "us";
          kb_variant = "";
          kb_model = "";
          kb_options = "";
          kb_rules = "";
          follow_mouse = 1;
          sensitivity = -0.5;
        };
      };

      curve = [
        {
          _args = [
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [
                  0.23
                  1
                ]
                [
                  0.32
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeInOutCubic"
            {
              type = "bezier";
              points = [
                [
                  0.65
                  0.05
                ]
                [
                  0.36
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "linear"
            {
              type = "bezier";
              points = [
                [
                  0
                  0
                ]
                [
                  1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  0.5
                ]
                [
                  0.75
                  1.0
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [
                  0.15
                  0
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 10;
          bezier = "default";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 5.39;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 4.79;
          bezier = "easeOutQuint";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 4.1;
          bezier = "easeOutQuint";
          style = "popin 87%";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.49;
          bezier = "linear";
          style = "popin 87%";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.73;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.46;
          bezier = "almostLinear";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 3.03;
          bezier = "quick";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 3.81;
          bezier = "easeOutQuint";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 4;
          bezier = "easeOutQuint";
          style = "fade";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.5;
          bezier = "linear";
          style = "fade";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.79;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.39;
          bezier = "almostLinear";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 1.21;
          bezier = "almostLinear";
          style = "fade";
        }
        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 1.94;
          bezier = "almostLinear";
          style = "fade";
        }
      ];

      # Autostart -- wrapped in hl.on("hyprland.start", ...) rather than a bare
      # top-level exec_cmd list, because exec_cmd calls that aren't event-hooked
      # re-run on every `hyprctl reload`, not just on the initial login.
      on = {
        _args = [
          "hyprland.start"
          (lib.generators.mkLuaInline ''
            function()
              hl.exec_cmd("swaync")
              hl.exec_cmd("systemctl --user start hyprpolkitagent")
              hl.exec_cmd("1password --silent")
              hl.exec_cmd("kdeconnect-indicator")
              hl.exec_cmd("tailscale-systray")
            end
          '')
        ];
      };

      # Keybindings
      bind = [
        # Basic application shortcuts
        {
          _args = [
            "ALT + T"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("ghostty")'')
          ];
        } # Open terminal
        {
          _args = [
            "ALT + C"
            (lib.generators.mkLuaInline "hl.dsp.window.close()")
          ];
        } # Close active window
        {
          _args = [
            "ALT + M"
            (lib.generators.mkLuaInline "hl.dsp.exit()")
          ];
        } # Exit Hyprland
        {
          _args = [
            "ALT + V"
            (lib.generators.mkLuaInline ''hl.dsp.window.float({ action = "toggle" })'')
          ];
        } # Toggle floating mode
        {
          _args = [
            "ALT + space"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("rofi -show drun -show-icons")'')
          ];
        } # Open application menu
        {
          _args = [
            "ALT + P"
            (lib.generators.mkLuaInline "hl.dsp.window.pseudo()")
          ];
        } # Toggle pseudotiling (dwindle layout)
        {
          _args = [
            "ALT + backslash"
            (lib.generators.mkLuaInline ''hl.dsp.layout("togglesplit")'')
          ];
        } # Toggle split direction (dwindle only)
        {
          _args = [
            "ALT + B"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("zen-beta")'')
          ];
        } # Open browser
        {
          _args = [
            "SUPER + SHIFT + 1"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("1password")'')
          ];
        } # Open 1Password
        {
          _args = [
            "SUPER + SHIFT + D"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("vesktop")'')
          ];
        } # Open Discord
        {
          _args = [
            "SUPER + SHIFT + S"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("spotify")'')
          ];
        } # Open Spotify
        {
          _args = [
            "SUPER + SHIFT + T"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("todoist-electron")'')
          ];
        } # Open Todoist
        {
          _args = [
            "SUPER + SHIFT + O"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("obsidian")'')
          ];
        } # Open Obsidian

        # Screenshot shortcuts
        {
          _args = [
            "SUPER + SHIFT + w"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m window")'')
          ];
        } # Screenshot window
        {
          _args = [
            "SUPER + SHIFT + f"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m active -m output")'')
          ];
        } # Screenshot fullscreen
        {
          _args = [
            "SUPER + SHIFT + r"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprshot -m region")'')
          ];
        } # Screenshot region

        # System shortcuts
        {
          _args = [
            "SUPER + SHIFT + l"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprlock")'')
          ];
        } # Lock screen

        # Window focus (vim-like navigation)
        {
          _args = [
            "ALT + h"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "l" })'')
          ];
        } # Focus left
        {
          _args = [
            "ALT + j"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "d" })'')
          ];
        } # Focus down
        {
          _args = [
            "ALT + k"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "u" })'')
          ];
        } # Focus up
        {
          _args = [
            "ALT + l"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ direction = "r" })'')
          ];
        } # Focus right

        # Window movement (Alt+Shift+vim keys)
        {
          _args = [
            "ALT + SHIFT + h"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "l" })'')
          ];
        } # Move window left
        {
          _args = [
            "ALT + SHIFT + j"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "d" })'')
          ];
        } # Move window down
        {
          _args = [
            "ALT + SHIFT + k"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "u" })'')
          ];
        } # Move window up
        {
          _args = [
            "ALT + SHIFT + l"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ direction = "r" })'')
          ];
        } # Move window right

        # Layout toggles (like aerospace)
        {
          _args = [
            "ALT + slash"
            (lib.generators.mkLuaInline "hl.dsp.group.toggle()")
          ];
        } # Toggle tabbed/stacked layout

        # Resize (like aerospace - smart resize)
        {
          _args = [
            "ALT + minus"
            (lib.generators.mkLuaInline "hl.dsp.window.resize({ x = -50, y = -50, relative = true })")
          ];
        } # Shrink window
        {
          _args = [
            "ALT + equal"
            (lib.generators.mkLuaInline "hl.dsp.window.resize({ x = 50, y = 50, relative = true })")
          ];
        } # Grow window

        # Workspace back-and-forth (like aerospace alt-tab)
        {
          _args = [
            "ALT + TAB"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "previous" })'')
          ];
        } # Switch to previous workspace

        # Workspace switching (1-10)
        {
          _args = [
            "ALT + 1"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 1 })")
          ];
        }
        {
          _args = [
            "ALT + 2"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 2 })")
          ];
        }
        {
          _args = [
            "ALT + 3"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 3 })")
          ];
        }
        {
          _args = [
            "ALT + 4"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 4 })")
          ];
        }
        {
          _args = [
            "ALT + 5"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 5 })")
          ];
        }
        {
          _args = [
            "ALT + 6"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 6 })")
          ];
        }
        {
          _args = [
            "ALT + 7"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 7 })")
          ];
        }
        {
          _args = [
            "ALT + 8"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 8 })")
          ];
        }
        {
          _args = [
            "ALT + 9"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 9 })")
          ];
        }
        {
          _args = [
            "ALT + 0"
            (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = 10 })")
          ];
        }

        # Move window to workspace (Alt + Shift + number)
        {
          _args = [
            "ALT + SHIFT + 1"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 1 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 2"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 2 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 3"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 3 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 4"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 4 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 5"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 5 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 6"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 6 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 7"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 7 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 8"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 8 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 9"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 9 })")
          ];
        }
        {
          _args = [
            "ALT + SHIFT + 0"
            (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = 10 })")
          ];
        }

        # Special workspace (scratchpad)
        {
          _args = [
            "ALT + S"
            (lib.generators.mkLuaInline ''hl.dsp.workspace.toggle_special("magic")'')
          ];
        } # Toggle magic workspace
        {
          _args = [
            "ALT + SHIFT + S"
            (lib.generators.mkLuaInline ''hl.dsp.window.move({ workspace = "special:magic" })'')
          ];
        } # Move to magic workspace

        # Mouse workspace navigation
        {
          _args = [
            "ALT + mouse_down"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "e+1" })'')
          ];
        } # Scroll to next workspace
        {
          _args = [
            "ALT + mouse_up"
            (lib.generators.mkLuaInline ''hl.dsp.focus({ workspace = "e-1" })'')
          ];
        } # Scroll to previous workspace

        # Multimedia keys (repeatable, work while locked)
        {
          _args = [
            "XF86AudioRaiseVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+")'')
            {
              locked = true;
              repeating = true;
            }
          ];
        } # Volume up
        {
          _args = [
            "XF86AudioLowerVolume"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-")'')
            {
              locked = true;
              repeating = true;
            }
          ];
        } # Volume down
        {
          _args = [
            "XF86AudioMute"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
            {
              locked = true;
              repeating = true;
            }
          ];
        } # Mute/unmute
        {
          _args = [
            "XF86AudioMicMute"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')
            {
              locked = true;
              repeating = true;
            }
          ];
        } # Mic mute/unmute
        {
          _args = [
            "XF86MonBrightnessUp"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+")'')
            {
              locked = true;
              repeating = true;
            }
          ];
        } # Brightness up
        {
          _args = [
            "XF86MonBrightnessDown"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-")'')
            {
              locked = true;
              repeating = true;
            }
          ];
        } # Brightness down

        # Media control keys (lockable, non-repeating)
        {
          _args = [
            "XF86AudioNext"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl next")'')
            { locked = true; }
          ];
        } # Next track
        {
          _args = [
            "XF86AudioPause"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
            { locked = true; }
          ];
        } # Play/pause
        {
          _args = [
            "XF86AudioPlay"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl play-pause")'')
            { locked = true; }
          ];
        } # Play/pause (alternative)
        {
          _args = [
            "XF86AudioPrev"
            (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("playerctl previous")'')
            { locked = true; }
          ];
        } # Previous track

        # Mouse bindings
        {
          _args = [
            "ALT + mouse:272"
            (lib.generators.mkLuaInline "hl.dsp.window.drag()")
            { mouse = true; }
          ];
        } # Alt + Left click + drag = move window
        {
          _args = [
            "ALT + mouse:273"
            (lib.generators.mkLuaInline "hl.dsp.window.resize()")
            { mouse = true; }
          ];
        } # Alt + Right click + drag = resize window
      ];

      # Window Rules
      # window_rule = [ ]; # none currently defined
    };
  };

  # Hyprland-related packages
  home.packages = with pkgs; [
    hyprshot # screenshot tool
    hyprpolkitagent # polkit agent
    hyprpicker # color picker

    # qt wayland library
    qt5.qtwayland
    qt6.qtwayland
  ];

  # Hyprland environment variables
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  # Hyprlock - screen locker
  programs.hyprlock = {
    enable = true;
    package = pkgs.hyprlock;
    settings = {
      background = {
        monitor = "";
        path = "~/dotfiles/wallpapers/spiderverse.jpg";
        color = "rgba(25, 20, 20, 1.0)";
        blur_passes = 2;
      };

      label = [
        {
          monitor = "";
          text = ''cmd[update:1000] echo "<b>$(date +'%H:%M:%S')</b>"'';
          color = "rgb(c0caf5)";
          font_size = 64;
          font_family = "JetBrains Mono Nerd Font";
          position = "0, -200";
          halign = "center";
          valign = "center";
        }
        {
          monitor = "";
          text = ''cmd[update:1000] echo "$(date +'%A, %B %d, %Y')"'';
          color = "rgb(a9b1d6)";
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

        outer_color = "rgba(7aa2f7ee) rgba(bb9af7ee) 45deg";
        check_color = "rgba(9ece6aee) rgba(e0af68ee) 120deg";
        fail_color = "rgba(f7768eee) rgba(ff9e64ee) 40deg";

        font_color = "rgb(c0caf5)";
        fade_on_empty = false;
        rounding = 15;

        position = "0, -20";
        halign = "center";
        valign = "center";
      };
    };
  };

  services = {
    # Hypridle - idle management daemon
    hypridle = {
      enable = true;
      package = pkgs.hypridle;
      settings = {
        general = {
          lock_cmd = "pidof hyprlock || hyprlock"; # avoid starting multiple hyprlock instances.
          before_sleep_cmd = "loginctl lock-session"; # lock before suspend.
          after_sleep_cmd = "hyprctl dispatch dpms on"; # to avoid having to press a key twice to turn on the display.
        };

        # turn off keyboard backlight, comment out this section if you dont have a keyboard backlight.
        listener = [
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -s set 10"; # set monitor backlight to minimum, avoid 0 on OLED monitor.
            on-resume = "brightnessctl -r"; # monitor backlight restore.
          }
          {
            timeout = 150; # 2.5min.
            on-timeout = "brightnessctl -sd rgb:kbd_backlight set 0"; # turn off keyboard backlight.
            on-resume = "brightnessctl -rd rgb:kbd_backlight"; # turn on keyboard backlight.
          }
          {
            timeout = 300; # 5min
            on-timeout = "loginctl lock-session"; # lock screen when timeout has passed
          }
          {
            timeout = 330; # 5.5min
            on-timeout = "hyprctl dispatch dpms off"; # screen off when timeout has passed
            on-resume = "hyprctl dispatch dpms on && brightnessctl -r"; # screen on when activity is detected after timeout has fired.
          }
          {
            timeout = 1800; # 30min
            on-timeout = "systemctl suspend"; # suspend pc
          }
        ];
      };
    };

    # Hyprpaper - wallpaper daemon
    hyprpaper = {
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

    # Hyprsunset - blue light filter
    hyprsunset = {
      enable = true;
      package = pkgs.hyprsunset;
      settings = {
        max-gamma = 150;

        profile = [
          {
            time = "7:00";
            identity = true;
          }
          {
            time = "18:00";
            temperature = 4500;
            gamma = 1.2;
          }
        ];
      };
    };
  };
}
