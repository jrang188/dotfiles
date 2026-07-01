{ pkgs, ... }: {
  programs.tmux = {
    enable = true;
    focusEvents = true;
    baseIndex = 1;
    keyMode = "vi";
    mouse = true;
    sensibleOnTop = true;
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      vim-tmux-navigator
      yank
      tokyo-night-tmux
    ];
  };
}
