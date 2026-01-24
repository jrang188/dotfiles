{ pkgs, ... }: {
  home.packages = with pkgs; [
    wl-clipboard # Implements wl-copy and wl-paste
    chntpw
    clang # macos have clang installed by default
  ];
}
