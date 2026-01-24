_: {
  # Reusable GUI configuration
  # This provides a base ghostty configuration that can be overridden by host-specific configs

  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      theme = "TokyoNight";
      background-opacity = 0.88;
      background-blur = true;
    };
    enableZshIntegration = true;
  };
}
