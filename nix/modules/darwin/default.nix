{ pkgs, pkgs-stable, ... }:
{
  imports = [
    ./system.nix
    ./security.nix
  ];

  nixpkgs.config = {
    allowUnfree = true;
    allowBroken = true;
    # Several packages depend on pinned pnpm versions that are currently marked
    # insecure (e.g. unocss-language-server). Permit them until upstream
    # nixpkgs updates the dependent packages.
    permittedInsecurePackages = [
      "pnpm-9.15.9"
      "pnpm-10.34.0"
    ];
  };

  # Overlay to use stable pre-commit on Darwin to avoid dotnet dependency
  # See: https://github.com/NixOS/nixpkgs/issues/450554
  nixpkgs.overlays = [
    (final: prev: {
      inherit (pkgs-stable) pre-commit;
    })
  ];

  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    optimise = {
      interval = {
        Weekday = 1;
        Hour = 2;
        Minute = 0;
      };
    };
  };
}
