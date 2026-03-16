{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================
    # Nix & Editor Tools
    # ============================================
    nil # Nix language server
    nixd # Another Nix language server
    nixfmt # Nix formatter
    nixfmt-tree # Nix formatter (tree-sitter based)
    statix # Nix linter

    # ============================================
    # General Utilities
    # ============================================
    jq # JSON processor
    fzf # Fuzzy finder
    fd # Fast find alternative
    ripgrep # Fast grep alternative
    bat # Cat with syntax highlighting
    tree # Directory tree viewer
    cmatrix # Matrix-style terminal animation
    stow # Symlink manager
    openssl # SSL/TLS toolkit
    lazygit # Git TUI
    xxd
    cachix

    # ============================================
    # Programming Languages & Runtimes
    # ============================================
    nodejs
    uv # Fast Python package installer
    python3 # Python interpreter
    go # Go programming language
    bun # Fast JavaScript runtime
    rustup # Rust toolchain installer
    javaPackages.compiler.temurin-bin.jdk-21 # Temurin 21
    gradle # Java build tool
    maven # Java build tool

    # ============================================
    # Development Tools
    # ============================================
    gh # GitHub CLI
    stripe-cli # Stripe CLI
    _1password-cli # 1Password CLI
    gnumake # Build automation tool
    golangci-lint # Go linter
    spring-boot-cli # Spring Boot CLI
    pre-commit # Git hooks framework
    devenv # Development environment manager
    codecrafters-cli # Codecrafters CLI
    devbox
    pnpm
    yarn-berry

    # ============================================
    # DevOps & Cloud Tools
    # ============================================
    tenv # Terraform version manager
    kubernetes-helm # Kubernetes package manager
    kubectl # Kubernetes CLI
    kubectx # Kubernetes context switcher
    k9s # Kubernetes TUI
    awscli2 # AWS CLI
    google-cloud-sdk # Google Cloud SDK
    oci-cli # Oracle Cloud Infrastructure CLI
    pulumi-bin # Infrastructure as code tool
    podman-tui # Podman TUI
    lazydocker
    kind
    minikube
  ];

  # Enable Nix-Direnv
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
