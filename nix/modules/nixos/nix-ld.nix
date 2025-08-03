{ ... }:
{
  # Needed for VScode in WSL (Workaround)
  programs.nix-ld = {
    enable = true;
  };

}
