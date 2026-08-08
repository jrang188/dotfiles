# nix/modules/darwin/

## Responsibility
macOS-specific nix-darwin system modules that configure system preferences, security (Touch ID), Nix daemon settings for macOS, and permitted insecure packages. These modules only activate on Sterling-MBP (Darwin).

## Design
- **Aggregation entry point**: `default.nix` re-exports two leaf modules (`system.nix`, `security.nix`) and additionally contributes inline config for nixpkgs config, Nix daemon settings, and automatic GC/optimization (matching NixOS's `nix.gc.automatic` + `auto-optimise-store` pattern).
- **Lix on Darwin**: `nix.package = pkgs.lixPackageSets.stable.lix` replaces the upstream Nix daemon binary with Lix (fork). The host config no longer relies on the Determinate Nix installer; `nix.enable` is intentionally not set here.
- **No module option declarations**: All three files (`default.nix`, `system.nix`, `security.nix`) assign nix-darwin option values directly without defining custom options. The module interface is purely the nix-darwin options namespace.

## Flow
1. `hosts/darwin/Sterling-MBP/default.nix` imports `../../../modules/darwin`.
2. Nix resolves to `modules/darwin/default.nix`, which imports `./system.nix` and `./security.nix`.
3. `default.nix` also inlines:
   - `nixpkgs.config.permittedInsecurePackages` — allows `pnpm-9.15.9`.
   - `nix.package` — pins Lix from the stable Lix package set.
   - `nix.settings.auto-optimise-store = true` — deduplicates identical store files via hardlinks (post-build).
   - `nix.optimise.interval` — weekly full store optimization on Monday at 02:00.
   - `nix.gc` — weekly automatic GC on Sunday at 03:00 with `--delete-older-than 7d` retention.
4. `system.nix` sets `system.stateVersion = 5`, `system.primaryUser`, dock preferences (autohide off, tilsize 24, no recents, disable bottom-right hot corner), key repeat rate, and installs `sketchybar-app-font`.
5. `security.nix` enables Touch ID for sudo via `security.pam.services.sudo_local` with `enable`, `touchIdAuth`, and `reattach` all set to `true`.

## Integration
- **Depends on**: `pkgs`, `username` (passed as function arguments from the host config).
- **Imported by**: `hosts/darwin/Sterling-MBP/default.nix`.
- **Also consumed (via common)**: `modules/common` is separately imported by the host for cross-platform settings.
- **Key option interactions**:
  - `nix.enable` is not set here; the Darwin host config provides its own Nix daemon binary via `nix.package` (Lix), so the nix-darwin module does not manage the daemon's lifecycle.
  - `fonts.packages` from `system.nix` is additive with the font list from `modules/common/nix-core.nix`.
  - `nixpkgs.config` from `default.nix` merges with `modules/common/nix-core.nix`'s `nixpkgs.config`.

### Module: `default.nix`
- **Purpose**: Darwin-specific nixpkgs configuration, Nix daemon settings (package, optimize, GC).
- **Key assignments**:
  - `nixpkgs.config.permittedInsecurePackages`: allows a pinned pnpm version (9.15.9).
  - `nix.package = pkgs.lixPackageSets.stable.lix`.
  - `nix.settings.auto-optimise-store = true` — hardlinks identical files across store paths (post-build daemon step, ~5-15s overhead per rebuild).
  - `nix.optimise.interval = { Weekday = 1; Hour = 2; Minute = 0; }` — weekly full store optimisation (Monday 02:00).
  - `nix.gc.automatic = true` — weekly automatic garbage collection (Sunday 03:00).
  - `nix.gc.options = lib.mkDefault "--delete-older-than 7d"` — matches NixOS 7-day retention.
  - `nix.gc.interval = { Weekday = 0; Hour = 3; Minute = 0; }` — Sunday 03:00, avoids overlap with optimise.

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
