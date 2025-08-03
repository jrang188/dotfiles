{ pkgs, lib, ... }:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    date = "weekly";
    options = lib.mkDefault "--delete-older-than 7d";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
}
