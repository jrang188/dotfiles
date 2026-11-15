{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  llm = inputs.llm-agents.packages.${system};
in
{
  # Codex CLI. Config and auth stay in ~/.codex, outside of Nix.
  # "Codex desktop" is the ChatGPT desktop app — Codex became a mode inside it
  # in 2026-07 and there is no separate Codex app installer anymore.
  home.packages = [ llm.codex ] ++ lib.optional pkgs.stdenv.hostPlatform.isDarwin llm.chatgpt;
}
