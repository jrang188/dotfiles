{ pkgs, ... }:
{
  # Override ghostty package for Darwin (use ghostty-bin)
  programs.ghostty.package = pkgs.ghostty-bin;
}
