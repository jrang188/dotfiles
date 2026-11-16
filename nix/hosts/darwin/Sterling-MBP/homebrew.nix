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

    # Every remaining install is from homebrew-core, so no taps are needed:
    # `felixkratz/formulae` was dropped 2026-11 when `sketchybar` moved to
    # `programs.sketchybar` and `borders` became `pkgs.jankyborders`.
    taps = [ ];

    brews = [
      "kafka"
      "mole"
      # MediaRemote client for the sketchybar media widget. `nowplaying-cli`
      # returns null for every key on macOS 26 while this one works, and it is
      # not in nixpkgs. Reaches the bar via the wrapper's /opt/homebrew/bin.
      "media-control"
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
