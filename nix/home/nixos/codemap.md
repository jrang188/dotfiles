# nix/home/nixos/

## Responsibility

NixOS Home Manager directory — serves as a namespace container for NixOS-specific home configs. Does **not** contain a `default.nix` (no shared NixOS-only home config exists). Instead, it hosts subdirectories for individual NixOS hosts: `kirby/` (active) and `wsl/` (orphaned).

## Design

- **Namespace directory**: No module logic at this level. The folder structure separates NixOS home configs from Darwin and shared configs.
- **Two subdirectories**:
  - `kirby/` — active, wired into `flake.nix` outputs (host `kirby`, x86_64-linux).
  - `wsl/` — orphaned, **not exported** from `flake.nix` (left over from a prior WSL iteration).

## Flow

Not applicable — no module is defined at this directory level. Host-specific configs are imported directly by `flake.nix` (`./home/nixos/kirby`).

## Integration

- **Active consumer**: `nix/flake.nix` line 199 — `homeImports = [ ./home ./home/nixos/kirby ]`.
- **Orphaned subdirectory**: `nix/home/nixos/wsl/` — present in the filesystem but not referenced in any flake output.
- **Sibling**: `nix/home/darwin/` for the macOS counterpart.
