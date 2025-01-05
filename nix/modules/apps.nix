{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    git
    nil
    alejandra
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
    # TODO Feel free to add your favorite apps here.
    brews = [
      "btop"
      "fastfetch"
      "ffmpeg"
      "fnm"
      "gh"
      "helm"
      "neofetch"
      "stow"
      "tenv"
      "wget"
      "curl"
      "defanglabs/defang/defang"
      "oven-sh/bun/bun"
      "stripe/stripe-cli/stripe"
    ];

    # `brew install --cask`
    # TODO Feel free to add your favorite apps here.
    casks = [
      "1password-cli"
      "raycast"
      "scroll-reverser"
      "warp"
    ];
  };
}
