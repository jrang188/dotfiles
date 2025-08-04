{ pkgs-unstable, ... }:
{
  environment.systemPackages = with pkgs-unstable; [
    sbctl
    niv
  ];
}
