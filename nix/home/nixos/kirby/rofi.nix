{ pkgs, lib, ... }:
{
  programs.rofi = {
    enable = true;
    # Use the absolute Nix store path for the terminal
    terminal = "${lib.getExe pkgs.ghostty}";
    modes = [
      "drun"
      "window"
      "run"
      "emoji"
      "calc"
    ];
    plugins = with pkgs; [
      rofi-calc
      rofi-emoji
    ];
    extraConfig = {
      icon-theme = "Papirus-Dark";
      show-icons = true;
      drun-display-format = "{icon} {name}";
      location = 0;
      disable-history = false;
      sidebar-mode = false;

      # Display characters (Nerd Fonts)
      display-drun = " ";
      display-run = " ";
      display-window = " ";
      display-emoji = " ";
      display-calc = " ";

      # Vim Keybindings
      kb-row-up = "Up,Control+k";
      kb-row-left = "Left,Control+h";
      kb-row-right = "Right,Control+l";
      kb-row-down = "Down,Control+j";
      kb-accept-entry = "Control+z,Control+y,Return,KP_Enter";

      # Text editing fixes
      kb-remove-to-eol = "";
      kb-move-char-back = "Control+b";
      kb-remove-char-back = "BackSpace";
      kb-move-char-forward = "Control+f";
      kb-mode-complete = "Control+o";
    };

    # Theme configuration
    # If your theme file is in the same folder as your nix file:
    theme = ./tokyonight.rasi;
  };
}
