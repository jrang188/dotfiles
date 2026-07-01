# nix/modules/darwin/

## Responsibility
macOS-specific nix-darwin system modules that configure system preferences, security (Touch ID), Nix daemon settings for macOS, and platform-specific package overrides (pre-commit from stable, permitted insecure packages). These modules only activate on Sterling-MBP (Darwin).

## Design
- **Aggregation entry point**: `default.nix` re-exports two leaf modules (`system.nix`, `security.nix`) and additionally contributes inline config for nixpkgs overrides, Nix daemon optimization, and the pre-commit overlay.
- **Overlay pattern for pre-commit**: Uses `nixpkgs.overlays = [ (final: prev: { inherit (pkgs-stable) pre-commit; }) ]` to substitute the `pre-commit` package from `pkgs-stable`, avoiding a `dotnet` build failure in unstable nixpkgs (see [NixOS/nixpkgs#450554](https://github.com/NixOS/nixpkgs/issues/450554)).
- **Determinate Nix constraint**: `nix.enable` is intentionally **not set** here — it defaults to `false` because Determinate Nix manages the Nix daemon on Darwin. This is a documented project-wide convention.
- **No module option declarations**: All three files (`default.nix`, `system.nix`, `security.nix`) assign nix-darwin option values directly without defining custom options. The module interface is purely the nix-darwin options namespace.

## Flow
1. `hosts/darwin/Sterling-MBP/default.nix` imports `../../../modules/darwin`.
2. Nix resolves to `modules/darwin/default.nix`, which imports `./system.nix` and `./security.nix`.
3. `default.nix` also inlines:
   - `nixpkgs.config.permittedInsecurePackages` — allows `pnpm-9.15.9` and `pnpm-10.34.0`.
   - `nixpkgs.overlays` — overrides `pre-commit` from `pkgs-stable`.
   - `nix.package` — pins Nix package.
   - `nix.optimise.interval` — weekly optimization on Monday at 02:00.
4. `system.nix` sets `system.stateVersion = 5`, `system.primaryUser`, dock preferences (autohide off, tilsize 24, no recents, disable bottom-right hot corner), key repeat rate, and installs `sketchybar-app-font`.
5. `security.nix` enables Touch ID for sudo via `security.pam.services.sudo_local.touchIdAuth = true`.

## Integration
- **Depends on**: `pkgs`, `pkgs-stable`, `username` (passed as function arguments from the host config).
- **Imported by**: `hosts/darwin/Sterling-MBP/default.nix`.
- **Also consumed (via common)**: `modules/common` is separately imported by the host for cross-platform settings.
- **Key option interactions**:
  - `nix.enable` is not set here; the Darwin host config relies on the Determinate Nix installer managing the Nix daemon.
  - `fonts.packages` from `system.nix` is additive with the font list from `modules/common/nix-core.nix`.
  - `nixpkgs.config` from `default.nix` merges with `modules/common/nix-core.nix`'s `nixpkgs.config`.

### Module: `default.nix`
- **Purpose**: Darwin-specific nixpkgs configuration, pre-commit overlay, Nix package/optimize settings.
- **Key assignments**:
  - `nixpkgs.config.permittedInsecurePackages`: allows two pinned pnpm versions.
  - `nixpkgs.overlays`: overrides `pre-commit` from `pkgs-stable` (overlay pattern).
  - `nix.package = pkgs.nix`.
  - `nix.optimise.interval = { Weekday = 1; Hour = 2; Minute = 0; }`.

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
- **Key assignment**: `security.pam.services.sudo_local.touchIdAuth = true`.
