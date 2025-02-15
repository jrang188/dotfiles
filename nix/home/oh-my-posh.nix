{ pkgs-unstable, ... }:
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "tokyonight_storm";
    package = pkgs-unstable.oh-my-posh;
  };
}
