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
    # Workaround for nixpkgs#536039 — V8's std::hash<int> specialization causes
    # an ODR violation with libc++ 21 (shipped in current stdenv), which makes
    # nodejs_24 emit spurious "File descriptor X opened/closed in unmanaged
    # mode" warnings from pnpm 11's worker pool. Rebuilding against libc++ 20
    # sidesteps the ODR. Cosmetic only — the FDs are actually fine. Safe to
    # drop once nixpkgs nodejs_24 ships with a V8 that includes upstream
    # commit v8/v8@65ce14d8 (Node 24.17+ / 25.x). Note: in current nixpkgs
    # `nodejs_24` is a symlinkJoin wrapper over `nodejs-slim_24`, so
    # rebuilding the slim derivation propagates to the alias. A plain
    # `.override { stdenv = ... }` does not work because v24.nix's
    # let-bound `buildNodejs = callPackage ./nodejs.nix { ... }` captures
    # the stdenv from the package set's autoArgs via the callPackage
    # passed in as an argument, ignoring the outer override. We pass an
    # injecting callPackage to v24.nix that forces libcxxStdenv into the
    # inner callPackage.
    (final: prev: {
      nodejs-slim_24 =
        let
          libcxxStdenv = final.buildPackages.llvmPackages_20.libcxxStdenv;
          baseCallPackage = prev.lib.callPackageWith prev;
          injectingCallPackage = fn: args: baseCallPackage fn (args // { stdenv = libcxxStdenv; });
        in
        baseCallPackage (prev.path + "/pkgs/development/web/nodejs/v24.nix") {
          stdenv = libcxxStdenv;
          callPackage = injectingCallPackage;
        };
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
