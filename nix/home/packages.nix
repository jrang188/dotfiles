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

    # Programming Languages
    fnm
    uv
    go
    bun
    rustup

    # Dev Tools
    gh
    stripe-cli

    # DevOps
    tenv
    helm
    kubectl
    kubectx
    k9s
    awscli
    pulumi
    awscli2
    google-cloud-sdk
    _1password-cli
  ];
}
