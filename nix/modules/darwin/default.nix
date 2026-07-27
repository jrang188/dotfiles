{ pkgs, ... }:
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
    ];
  };

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
