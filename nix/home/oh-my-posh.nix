{ pkgs, ... }:
{
  programs.oh-my-posh = {
    enable = true;
    enableZshIntegration = true;
    useTheme = "tokyonight_storm";
    package = pkgs.oh-my-posh;
  };
}
