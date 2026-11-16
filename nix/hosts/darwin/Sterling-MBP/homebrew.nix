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
    };

    taps = [
      "felixkratz/formulae"
    ];

    # `brew install`
    # Non-official taps require tap trust (Homebrew 6+). Fully-qualified
    # names let nix-darwin emit `trusted: true` in the generated Brewfile,
    # which records the trust during activation before anything is loaded.
    brews = [
      {
        name = "felixkratz/formulae/borders";
        trusted = true;
      }
      "kafka"
      "mole"
      "scrcpy"
      "nss"
    ];

    # `brew install --cask`
    casks = [
      "raycast"
      "scroll-reverser"
      "warp"
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
