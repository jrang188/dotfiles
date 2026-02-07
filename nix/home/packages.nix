{ pkgs, ... }: {
  home.packages = with pkgs; [
    # ============================================
    # Nix & Editor Tools
    # ============================================
    nil # Nix language server
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
    direnv # Environment variable manager
    lazygit # Git TUI
    xxd

    # ============================================
    # Programming Languages & Runtimes
    # ============================================
    fnm # Fast Node.js version manager
    uv # Fast Python package installer
    python3 # Python interpreter
    go # Go programming language
    bun # Fast JavaScript runtime
    rustup # Rust toolchain installer
    javaPackages.compiler.temurin-bin.jdk-25 # Temurin 25
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
    claude-code # Claude AI coding assistant
    pre-commit # Git hooks framework
    devenv # Development environment manager
    codecrafters-cli # Codecrafters CLI

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
  ];
}
