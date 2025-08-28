{ pkgs-unstable, pkgs, ... }:
{
  home.packages = with pkgs-unstable; [
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
    bat

    # Programming Languages
    fnm
    uv
    python3
    go
    bun
    rustup
    temurin-bin
    gradle
    maven

    # Dev Tools
    gh
    stripe-cli
    _1password-cli
    gnumake
    golangci-lint
    spring-boot-cli
    claude-code
    nixfmt-tree
    pre-commit

    # DevOps
    tenv
    kubernetes-helm
    kubectl
    kubectx
    k9s
    awscli2
    google-cloud-sdk
    oci-cli
    pulumi-bin
    lazydocker
  ];
}
