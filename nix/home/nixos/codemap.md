# nix/home/nixos/

## Responsibility

NixOS Home Manager directory — serves as a namespace container for NixOS-specific home configs. Does **not** contain a `default.nix` (no shared NixOS-only home config exists). Instead, it hosts subdirectories for individual NixOS hosts: `kirby/` (the only one, active).

## Design

- **Namespace directory**: No module logic at this level. The folder structure separates NixOS home configs from Darwin and shared configs.
- **Single subdirectory**:
  - `kirby/` — active, wired into `flake.nix` outputs (host `kirby`, x86_64-linux).
- The former `wsl/` config has been removed from the tree; do not re-add it or other orphaned WSL/Ubuntu configs without confirming with the user.

## Flow

Not applicable — no module is defined at this directory level. Host-specific configs are imported directly by `flake.nix` (`./home/nixos/kirby`).

## Integration

- **Active consumer**: `nix/flake.nix` lines 187–190 — `homeImports = [ ./home ./home/nixos/kirby ]`.
- **Sibling**: `nix/home/darwin/` for the macOS counterpart.
