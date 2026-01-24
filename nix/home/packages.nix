{ pkgs, ... }: {
  home.packages = with pkgs; [
    nil
    nixfmt
    jq
    fzf
    fd
    ripgrep
    lazygit
    tree
    cmatrix
    stow
    bat
    openssl
    direnv

    # Programming Languages
    fnm
    uv
    python3
    go
    bun
    rustup
    temurin-bin # defaults to jdk21 for now
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
    statix
    devenv

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
    podman-tui
  ];
}
