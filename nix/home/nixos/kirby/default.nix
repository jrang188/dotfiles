{ ... }:
{
  imports = [
    ../clang.nix
    ./apps.nix
    ./packages.nix
    ./zen-browser.nix
    ./hypr
    ../gui/ghostty.nix
  ];
}
