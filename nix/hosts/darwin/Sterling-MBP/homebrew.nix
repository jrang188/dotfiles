_: {
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      upgrade = true;
      # Bundle cleanup can try to remove libraries still needed by installed
      # formulae, aborting activation. Clean up unwanted packages manually.
      cleanup = "none";

      # Existing tap-trust workaround; this variable is deprecated by Homebrew.
      extraEnv = {
        HOMEBREW_NO_REQUIRE_TAP_TRUST = "1";
      };
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
      "lua"
      "kafka"
      "mole"
      "media-control"
      "scrcpy"
      "nss"
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
      "kde-connect"
    ];
  };
}
