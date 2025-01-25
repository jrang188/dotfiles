{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    git
    btop
    fastfetch
    ffmpeg
    wget
    curl
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
    ];

    # `brew install`
    brews = [
    ];

    # `brew install --cask`
    casks = [
      "raycast"
      "scroll-reverser"
      "warp"
      "ghostty"
    ];
  };
}
