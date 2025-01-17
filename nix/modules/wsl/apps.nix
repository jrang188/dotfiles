{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    nil
    nixfmt-rfc-style
    btop
    fastfetch
    ffmpeg
    neofetch
    stow
    wget
    curl
    htop

    # Programming Languages
    fnm
    uv
    go
    bun

    # Dev Tools
    gh
    stripe-cli
    gnumake

    # DevOps
    tenv
    kubernetes-helm
    kubectl
    kubectx
    awscli
    pulumi-bin
    google-cloud-sdk
  ];
}
