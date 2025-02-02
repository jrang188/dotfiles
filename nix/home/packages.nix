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
    cmatrix
    stow

    # Programming Languages
    fnm
    uv
    go
    bun
    rustup
    clang
    python3

    # Dev Tools
    gh
    stripe-cli
    _1password-cli
    gnumake

    # DevOps
    tenv
    kubernetes-helm
    kubectl
    kubectx
    k9s
    pulumi-bin
    awscli2
    google-cloud-sdk
  ];
}
