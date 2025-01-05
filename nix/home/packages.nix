{pkgs, ...}: {
  home.packages = with pkgs; [
    jq
    fzf
    fd
    ripgrep
    lazygit
    tree
    rustup
  ];
}
