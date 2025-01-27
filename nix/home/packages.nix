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
    pulumi
    awscli2
    google-cloud-sdk
  ];
}
