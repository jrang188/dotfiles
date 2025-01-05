{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    nil
    nixfmt-rfc-style
  ];

  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";
    };

    taps = [
      "homebrew/services"
      "defanglabs/defang"
      "jandedobbeleer/oh-my-posh"
      "oven-sh/bun"
      "stripe/stripe-cli"
    ];

    # `brew install`
    brews = [
      "btop"
      "fastfetch"
      "ffmpeg"
      "neofetch"
      "stow"
      "wget"
      "curl"

      # Programming Languages
      "fnm"
      "uv"
      "go"
      "oven-sh/bun/bun"

      # Dev Tools
      "gh"
      "stripe/stripe-cli/stripe"

      # DevOps
      "tenv"
      "helm"
      "defanglabs/defang/defang"
      "kubectl"
      "kubectx"
      "k9s"
      "awscli"
      "pulumi"
    ];

    # `brew install --cask`
    casks = [
      "1password-cli"
      "raycast"
      "scroll-reverser"
      "warp"
      "google-cloud-sdk"
    ];
  };
}
