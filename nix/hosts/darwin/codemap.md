# nix/hosts/darwin/

## Responsibility
Namespace directory for nix-darwin (macOS) host configurations. Contains the single active Darwin host `Sterling-MBP/`. There is no `default.nix` at this level — host configs are referenced directly by path from `nix/flake.nix`.

## Design
- **Folder-as-namespace**: No aggregate module file; `darwin/` exists purely for organization alongside `nixos/`.
- **Single active host**: `Sterling-MBP/` is the only Darwin host and is the only host passed to `mkDarwin` in `flake.nix`.
- **Platform-specific module path**: Each host module under this tree is expected to import `../../../modules/common` and `../../../modules/darwin`, which provide shared and Darwin-specific system configuration (nix-core, security, system defaults).
- Host modules can also import platform flake inputs injected via `mkDarwin` (mac-app-util, nix-homebrew). The Nix daemon binary is Lix (`nix.package = pkgs.lixPackageSets.stable.lix`), configured in the shared `modules/common/nix-daemon.nix`; Determinate Nix is no longer used.

## Flow
1. `nix/flake.nix` calls `mkDarwin { hostname = "Sterling-MBP"; modules = [ ./hosts/darwin/Sterling-MBP ]; ... }`.
2. `mkDarwin` assembles the final `darwinSystem` by merging: host module → `mac-app-util.darwinModules.default` → `home-manager-darwin.darwinModules.home-manager` + Home Manager config → `nix-homebrew.darwinModules.nix-homebrew` (with Homebrew setup: `enable`, `enableRosetta`, `user`, `autoMigrate`). No Nix daemon module is injected — `nix.package` (Lix) comes from the shared `modules/common/nix-daemon.nix`, and `nix.enable` is not set.
3. The host module itself imports shared modules and configures hostname, users, dock, and homebrew taps/brews/casks.
4. `make darwin` or `darwin-rebuild switch --flake .#Sterling-MBP` materializes the final configuration.

## Integration
- **Consumer**: `nix/flake.nix` via `mkDarwin` — references `./hosts/darwin/Sterling-MBP` as the host module.
- **Provider to**: `Sterling-MBP/default.nix` imports `../../../modules/common` and `../../../modules/darwin`.
- **Related flake inputs**: `darwin` (nix-darwin), `mac-app-util`, `nix-homebrew`, `home-manager-darwin`.
