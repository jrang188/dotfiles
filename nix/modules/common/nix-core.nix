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
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 7d";
  };

  # fonts.packages = with pkgs; [
  #   nerd-fonts.fira-code
  #   nerd-fonts.jetbrains-mono
  # ];

  fonts.packages = with pkgs; [
    (nerdfonts.override {
      fonts = [
        "FiraCode"
        "JetBrainsMono"
      ];
    })
    fira-code
    jetbrains-mono
  ];

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
}
