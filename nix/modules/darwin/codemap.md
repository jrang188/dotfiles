# nix/modules/darwin/

## Responsibility
macOS-specific nix-darwin system modules that configure system preferences, security (Touch ID), permitted insecure packages, and the Darwin timer overlay on the shared Nix daemon config. These modules only activate on Sterling-MBP (Darwin).

## Design
- **Aggregation entry point**: `default.nix` is a **pure import list** (`system.nix`, `security.nix`, `insecure-packages.nix`) plus a small platform timer overlay for the shared `nix-daemon.nix`. The old inline `nixpkgs.config` and Lix/GC blocks were extracted into `insecure-packages.nix` and the common `nix-daemon.nix`.
- **Lix on Darwin**: `nix.package = pkgs.lixPackageSets.stable.lix` lives in the **shared** `modules/common/nix-daemon.nix`, not here. The host config no longer relies on the Determinate Nix installer; `nix.enable` is intentionally not set here.
- **No module option declarations**: The files assign nix-darwin option values directly without defining custom options. The module interface is purely the nix-darwin options namespace.

## Flow
1. `hosts/darwin/Sterling-MBP/default.nix` imports `../../../modules/darwin`.
2. Nix resolves to `modules/darwin/default.nix`, which imports `./system.nix`, `./security.nix`, and `./insecure-packages.nix`.
3. The shared `modules/common/nix-daemon.nix` (imported via `common`) sets `nix.package` (Lix), `auto-optimise-store`, and GC policy. `default.nix` overlays only the Darwin timer syntax:
   - `nix.optimise.interval` — weekly full store optimization on Monday at 02:00.
   - `nix.gc.interval` — weekly automatic GC on Sunday at 03:00.
4. `insecure-packages.nix` sets `nixpkgs.config.permittedInsecurePackages` — allows `pnpm-9.15.9`.
5. `system.nix` sets `system.stateVersion = 5`, `system.primaryUser`, dock preferences (autohide off, tilsize 24, no recents, disable bottom-right hot corner), key repeat rate, and installs `sketchybar-app-font`.
6. `security.nix` enables Touch ID for sudo via `security.pam.services.sudo_local` with `enable`, `touchIdAuth`, and `reattach` all set to `true`.

## Integration
- **Depends on**: `pkgs`, `username` (passed as function arguments from the host config).
- **Imported by**: `hosts/darwin/Sterling-MBP/default.nix`.
- **Also consumed (via common)**: `modules/common` is separately imported by the host for cross-platform settings, including the shared `nix-daemon.nix`.
- **Key option interactions**:
  - `nix.enable` is not set here; the Darwin host config provides its own Nix daemon binary via `nix.package` (Lix, from shared `nix-daemon.nix`), so the nix-darwin module does not manage the daemon's lifecycle.
  - `fonts.packages` from `system.nix` is additive with the font list from `modules/common/nix-core.nix`.
  - `nixpkgs.config` from `insecure-packages.nix` merges with `modules/common/nix-core.nix`'s `nixpkgs.config`.

### Module: `default.nix`
- **Purpose**: Pure import aggregator + Darwin timer overlay on the shared `nix-daemon.nix`.
- **Key assignments**:
  - Imports `./system.nix`, `./security.nix`, `./insecure-packages.nix`.
  - `nix.gc.interval = { Weekday = 0; Hour = 3; Minute = 0; }` — Sunday 03:00, avoids overlap with optimise.
  - `nix.optimise.interval = { Weekday = 1; Hour = 2; Minute = 0; }` — weekly full store optimisation (Monday 02:00).
  - The Lix package, `auto-optimise-store`, `gc.automatic`, and `gc.options` are **not** set here — they come from the shared `modules/common/nix-daemon.nix`.

### Module: `insecure-packages.nix`
- **File**: `modules/darwin/insecure-packages.nix`
- **Purpose**: Darwin-specific permitted insecure package list.
- **Key assignments**: `nixpkgs.config.permittedInsecurePackages = [ "pnpm-9.15.9" ]`.

### Module: `system.nix`
- **File**: `modules/darwin/system.nix`
- **Purpose**: macOS system state, primary user, dock configuration, keyboard repeat, activation scripts, fonts.
- **Key assignments**:
  - `system.stateVersion = 5`.
  - `system.primaryUser = username`.
  - `system.activationScripts.UserActivation.text`: calls `activateSettings -u` to apply system defaults without logout.
  - `system.defaults.dock.*`: autohide off, tilsize 24, no recents, br-corner disabled.
  - `system.defaults.NSGlobalDomain.KeyRepeat = 2`.
  - `fonts.packages = [ sketchybar-app-font ]`.

### Module: `security.nix`
- **File**: `modules/darwin/security.nix`
- **Purpose**: Touch ID sudo authentication.
- **Key assignments**: `security.pam.services.sudo_local = { enable = true; touchIdAuth = true; reattach = true; }`.
