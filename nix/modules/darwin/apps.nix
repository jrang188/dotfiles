_: {
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
      "grishka/grishka"
    ];

    # `brew install`
    brews = [
      "sketchybar"
      "borders"
      "lua"
      "kafka"
    ];

    # `brew install --cask`
    casks = [
      "raycast"
      "scroll-reverser"
      "warp"
      "aerospace"
      "karabiner-elements"
      "sf-symbols" # font for sketchybar
      "font-sf-mono"
      "font-sf-pro"
      "orbstack"
      "localsend"
      "grishka/grishka/neardrop"
    ];
  };
}
