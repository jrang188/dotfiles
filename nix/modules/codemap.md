# nix/modules/

## Responsibility
Entry-point directory for reusable NixOS and nix-darwin system modules and shared Home Manager modules. Serves as the canonical import path consumed by host-specific configurations (`hosts/darwin/Sterling-MBP/`, `hosts/nixos/kirby/`, and the orphaned `hosts/nixos/wsl/`). Each subdirectory (`common/`, `darwin/`, `nixos/`, `home/`) exposes its own `default.nix` that aggregates platform-specific or cross-platform functionality.

This directory does **not** have its own `default.nix` — it is a pure organizational namespace. Consumers import subdirectory paths directly (e.g. `../../../modules/common`, `../../../modules/nixos`).

## Design
- **Platform-split layout**: Modules are partitioned into `common/` (cross-platform), `darwin/` (macOS-only), `nixos/` (Linux/NixOS-only), and `home/` (Home Manager user-scoped configs).
- **Aggregation pattern**: Each subdirectory uses a top-level `default.nix` that re-exports its constituent modules via the standard Nix module `imports = [ ... ]` list.
- **No option definitions at root**: All option declarations and config assignments live inside leaf `.nix` files within the platform subdirectories. The root serves only as a flat namespace index.
- **Consumer-driven activation**: Host configs activate modules by adding them to their `imports` list. There is no global registry or module auto-discovery.

## Flow
1. A host config (e.g. `hosts/nixos/kirby/default.nix`) lists `../../../modules/common` and `../../../modules/nixos` in its `imports`.
2. Nix resolves `modules/common` → `modules/common/default.nix`, which in turn imports `./apps.nix`, `./nix-core.nix`, and `./nix-daemon.nix` (shared Nix daemon Lix/GC config, imported by both platforms).
3. Nix resolves `modules/nixos` → `modules/nixos/default.nix`, which imports `./flatpak.nix`, `./nix-ld.nix`, `./1password.nix`, `./hyprland.nix`, `./podman.nix`, `./localsend.nix`, and `./user-shell.nix`. NixOS leaves hold platform-specific timers (`gc.dates`, `optimise.automatic`) that overlay the shared `nix-daemon.nix` defaults.
4. Nix resolves `modules/darwin` → `modules/darwin/default.nix`, which imports `./system.nix`, `./security.nix`, and `./insecure-packages.nix`, plus the Darwin timer overlay (`gc.interval`, `optimise.interval`) on the shared `nix-daemon.nix`.
5. All resolved module definitions and configs are merged by Nix's module system into a single attribute set, with `mkIf`/`mkDefault`/`mkMerge` resolving conflicts per standard Nix semantics.
6. Home Manager host configs independently import `modules/home/gui.nix` to apply user-scoped settings.

## Integration
- **Consumed by**: `hosts/darwin/Sterling-MBP/default.nix` (imports `common` + `darwin`), `hosts/nixos/kirby/default.nix` (imports `common` + `nixos`), `hosts/nixos/wsl/default.nix` (imports `common` only).
- **Consumed by**: `home/darwin/default.nix` and `home/nixos/kirby/default.nix` (import `modules/home/gui.nix` directly).
- **Not consumed by**: `flake.nix` — the flake does not reference this directory directly; it is purely a path-based import target.
