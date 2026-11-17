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

    # Every remaining install is from homebrew-core, except `anomalyco/tap`
    # below (`hex` predates its Nix package on macOS-only hosts):
    # `felixkratz/formulae` was dropped 2026-11 when `sketchybar` moved to
    # `programs.sketchybar` and `borders` became `pkgs.jankyborders`.
    taps = [
      # Hex's cask tap (`brew install --cask anomalyco/tap/hex`). Hex's Nix
      # package is Linux-only, so on Darwin the cask is the supported install.
      "anomalyco/tap"
    ];

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
      "anomalyco/tap/hex"
    ];
  };

  # Homebrew (since 6.0 via HOMEBREW_REQUIRE_TAP_TRUST) refuses to load casks
  # from an untrusted third-party tap: `brew install --cask anomalyco/tap/hex`
  # fails with "Refusing to load cask ... from untrusted tap". No extra option
  # is needed here -- nix-darwin's `homebrew.casks` entries default to
  # `trusted = true`, so activation writes
  # `cask "anomalyco/tap/hex", trusted: true` into the Brewfile, which both
  # installs the cask and records it in `brew trust` (verified 2026-11-16).
  # The tap itself stays untrusted, which is narrower than `trust.taps`.
}
