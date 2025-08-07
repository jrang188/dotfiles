{
  pkgs,
  pkgs-unstable,
  lib,
  ...
}:
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
    options = lib.mkDefault "--delete-older-than 7d";
  };

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.jetbrains-mono
  ];

  # Ensure all systems uses zsh
  # DARWIN SPECIFIC NOTES:
  # Create /etc/zshrc that loads the nix-darwin environment.
  # this is required if you want to use darwin's default shell - zsh
  programs.zsh.enable = true;

  # Auto upgrade nix package and the daemon service.
  nix.package = pkgs.nix;
}
