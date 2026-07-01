# nix/hosts/

## Responsibility
Logical namespace grouping platform-specific host configurations. There is no `default.nix` here — this directory is purely a container for the `darwin/` and `nixos/` subdirectories. The actual dispatch to host configs is driven directly from `nix/flake.nix` via the `mkDarwin` and `mkSystem` helper functions.

## Design
- **No module file at this level** — unlike most Nix directories, `hosts/` has no `default.nix`. It is strictly a filesystem grouping convention per the repository standard.
- **Two subdirectories** reflecting the two supported platforms: `darwin/` (macOS, aarch64) and `nixos/` (NixOS, x86_64).
- Each subdirectory contains host-specific Nix modules that define `nix-darwin` or `nixos-rebuild` configuration attributes.
- The flake `mkDarwin` and `mkSystem` helpers receive the host module path (e.g., `./hosts/darwin/Sterling-MBP`) and compose it with shared modules, Home Manager, and any platform-specific flake inputs (lanzaboote, mac-app-util, nix-homebrew, etc.).

## Flow
1. `nix/flake.nix` defines the `outputs` with two host entries: `darwinConfigurations."Sterling-MBP"` and `nixosConfigurations."kirby"`.
2. Each entry passes a host-specific module directory (under this tree) to `mkDarwin` / `mkSystem`.
3. The helper function merges that host module with shared modules (`modules/common`, `modules/darwin` or `modules/nixos`), Home Manager configs, and flake-input modules (determinate, lanzaboote, mac-app-util, nix-homebrew, home-manager).
4. Build commands (`make darwin`, `make nixos`) invoke `nh darwin switch` / `nh os switch` which evaluate the final `darwinSystem` / `nixosSystem` from the flake.

## Integration
- **Upstream consumer**: `nix/flake.nix` — the flake entry point that wires each host path into a full system configuration.
- **Downstream providers**:
  - `./darwin/` — Darwin (macOS) host configs, referenced by `mkDarwin`.
  - `./nixos/` — NixOS host configs, referenced by `mkSystem`.
- **Shared modules consumed by hosts**: `modules/common`, `modules/darwin`, `modules/nixos` (imported by the host `default.nix` files via relative path `../../../modules/<platform>`).
