{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    focusEvents = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = true;
    prefix = "C-Space";
    terminal = "tmux-256color";
    historyLimit = 50000;
    customPaneNavigationAndResize = true; # prefix h/j/k/l select pane, repeatable prefix H/J/K/L resize
    disableConfirmationPrompt = true; # prefix x / & kill without confirmation
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      tokyo-night-tmux
    ];
    extraConfig = ''
      # Truecolor + undercurl support for Ghostty (LazyVim diagnostics/tokyonight)
      set -as terminal-features ",xterm-ghostty:RGB:usstyle"
      set -g set-clipboard on

      # Keep window numbers contiguous when closing windows
      set -g renumber-windows on

      # Splits open in the current working directory (LazyVim-style | and -,
      # plus the tmux defaults % and " so every new pane inherits cwd)
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"
      bind % split-window -h -c "#{pane_current_path}"
      bind '"' split-window -v -c "#{pane_current_path}"

      # New window opens in the current working directory
      bind c new-window -c "#{pane_current_path}"

      # Last window (matches Aerospace/Hyprland alt-tab muscle memory)
      bind Tab last-window

      # Reload config (uppercase R still works via tmux-sensible)
      bind r source-file ~/.config/tmux/tmux.conf \; display-message "tmux.conf reloaded"

      # Vim-like copy mode (y yanks to system clipboard via tmux-yank)
      bind -T copy-mode-vi v send-keys -X begin-selection
      bind -T copy-mode-vi C-v send-keys -X rectangle-toggle

    '';
  };
}
