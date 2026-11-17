{ inputs, ... }:
{
  # HEX local-first voice dictation (https://github.com/anomalyco/hex).
  # Declarative install via the upstream Home Manager module: the package, the
  # systemd --user service and the model downloader all come from the flake
  # input, so there is no `nix profile` entry to drift.
  imports = [ inputs.hex.homeManagerModules.hex ];

  programs.hex = {
    enable = true;

    # Start with the session rather than waiting for a manual launch.
    autostart = true;

    # graphical-session.target, not hyprland-session.target: the latter is
    # only started by wayland.windowManager.hyprland.systemd.enable, which is
    # false here (see the comment in hyprland.nix) -- under uwsm,
    # graphical-session.target is what actually comes up.
    systemdTarget = "graphical-session.target";

    # Fetch the selected transcription model at login if it is missing; models
    # live in ~/.local/share/hex, never in the Nix store, and activation itself
    # never downloads.
    installModel = true;
  };
}
