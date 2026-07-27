_: {
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      cleanup = "zap";

      # Workaround: Homebrew 6.x introduced tap trust, and `brew bundle
      # --force-cleanup` deletes `~/.homebrew/trust.json` on a failed cleanup,
      # so re-trusting via `brew trust` does not survive the next activation.
      # Disabling the requirement is the documented escape hatch.
      # TODO: remove when upstream fixes the trust.json clobber on cleanup failure,
      # or when nix-homebrew exposes a first-class way to pre-trust taps.
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
      };
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
      "mole"
      "media-control"
      "scrcpy"
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
      "intellij-idea"
      "zed"
      "google-drive"
      "adobe-acrobat-reader"
      "android-platform-tools"
    ];
  };
}
