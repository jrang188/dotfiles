{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixfmt-rfc-style
    jq
    fzf
    fd
    ripgrep
    lazygit
    tree
    rustup
  ];
}
