{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  llm = inputs.llm-agents.packages.${system};
in
{
  # Codex CLI. Config and auth stay in ~/.codex, outside of Nix.
  # "Codex desktop" is the ChatGPT desktop app — Codex became a mode inside it
  # in 2026-07 and there is no separate Codex app installer anymore. The Linux
  # build is in preview: native Wayland is experimental, so it prefers XWayland
  # (kirby sets programs.hyprland.xwayland.enable = true) and Computer Use is
  # unavailable there.
  home.packages = [
    llm.codex
    llm.chatgpt
  ];
}
