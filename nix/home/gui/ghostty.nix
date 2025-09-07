{ pkgs-unstable, ... }:
{
  programs.ghostty = {
    enable = true;
    package = pkgs-unstable.ghostty;
    settings = {
      font-family = "JetBrainsMono Nerd Font Mono";
      theme = "tokyonight";
      background-opacity = 0.88;
      background-blur = true;
    };
    enableZshIntegration = true;
  };
}
