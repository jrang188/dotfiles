_: {
  # Needed for VScode in WSL (Workaround)
  # Also needed for NIXOS when running non-nix management toolkits
  # e.g. FNM, possibly UV
  programs.nix-ld.enable = true;
}
