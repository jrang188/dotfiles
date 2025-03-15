{ ... }:
{
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
      "nikitabobko/tap"
      "FelixKratz/formulae"
      "homebrew/services"
    ];

    # `brew install`
    brews = [
      "sketchybar"
      "borders"
    ];

    # `brew install --cask`
    casks = [
      "raycast"
      "scroll-reverser"
      "warp"
      "ghostty"
      "aerospace"
      "karabiner-elements"
    ];
  };
}
