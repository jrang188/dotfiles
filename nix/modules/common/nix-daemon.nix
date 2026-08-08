{ pkgs, lib, ... }:
{
  nix = {
    package = pkgs.lixPackageSets.stable.lix;
    settings.auto-optimise-store = true;
    gc = {
      automatic = true;
      options = lib.mkDefault "--delete-older-than 7d";
    };
  };
}
