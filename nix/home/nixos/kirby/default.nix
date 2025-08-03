{ pkgs-unstable, ... }:
{
  imports = [
    ../clang.nix
    ./apps.nix
  ];
}
