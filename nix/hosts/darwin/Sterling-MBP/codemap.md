# nix/hosts/darwin/Sterling-MBP/

## Responsibility
Host-specific nix-darwin module for the **Sterling-MBP** machine (Apple Silicon MacBook Pro, `aarch64-darwin`). Defines the macOS system-level configuration: host identity, user account, dock-pinned applications, and Homebrew-managed packages that complement the Nix package set.

## Design
- **Module pattern**: A standard Nix module accepting `{ pkgs, username, hostname, ... }` from the flake's `specialArgs`.
- **Composition over inheritance**: Imports three layers — shared modules (`../../../modules/common`), Darwin platform modules (`../../../modules/darwin`), and this host's `./homebrew.nix`.
- **Mixed package management**: Combines Nix-managed packages (via shared/darwin modules) with Homebrew-managed GUI apps and CLI tools (via `nix-homebrew` flake input, configured in `flake.nix`). Homebrew `onActivation.cleanup = "zap"` ensures only listed formulae/casks remain installed.
- **Lix, not Determinate Nix**: Determinate Nix is no longer used. `nix.package = pkgs.lixPackageSets.stable.lix` comes from the shared `modules/common/nix-daemon.nix` (imported here via `../../../modules/common`); `nix.enable` is intentionally not set, so the nix-darwin module does not manage the daemon.
- **mac-app-util integration**: The `mac-app-util` flake input now follows `nixpkgs-darwin` (the independent pin was removed 2026-07 after the SBCL 2.6.0 build failure could not be reproduced). Its Darwin module and Home Manager module are imported in `mkDarwin`.

## Files
| File | Role |
|------|------|
| `default.nix` | Host module entry point. Imports shared/Darwin modules, sets `networking.hostName`, `networking.computerName`, `users.users.sirwayne`, `nix.settings.trusted-users`, and `system.defaults.dock.persistent-apps`. |
| `homebrew.nix` | Homebrew configuration: enables Homebrew, sets `onActivation.upgrade = true`, `onActivation.cleanup = "zap"`, and `onActivation.extraEnv.HOMEBREW_NO_REQUIRE_TAP_TRUST = "1"` (workaround for Homebrew 6.x tap trust: `brew bundle --force-cleanup` clobbers `~/.homebrew/trust.json` on cleanup failure); defines `taps`, `brews`, and `casks`. |

## Key Configuration Options
| Option | Value / Effect |
|--------|---------------|
| `networking.hostName` | `"Sterling-MBP"` (from flake's `hostname` arg) |
| `networking.computerName` | `"Sterling-MBP"` |
| `users.users.sirwayne.home` | `"/Users/sirwayne"` |
| `nix.settings.trusted-users` | `[ "sirwayne" ]` |
| `system.defaults.dock.persistent-apps` | Ordered list of 14 apps (Apps, Zen Browser, Ghostty, Zed, VS Code, IntelliJ IDEA, OpenCode, Claude, Antigravity, Antigravity IDE, Obsidian, Discord, Spotify, System Settings) |
| `homebrew.enable` | `true` |
| `homebrew.onActivation.cleanup` | `"zap"` — uninstalls unlisted formulae/casks |
| `homebrew.onActivation.extraEnv` | `HOMEBREW_NO_REQUIRE_TAP_TRUST = "1"` — escape hatch for the Homebrew 6.x tap-trust/`trust.json` clobber workaround |
| `homebrew.taps` | `nikitabobko/tap`, `FelixKratz/formulae`, `homebrew/services` |
| `homebrew.brews` | sketchybar, borders, lua, kafka, mole, media-control, scrcpy, nss |
| `homebrew.casks` | raycast, scroll-reverser, warp, aerospace, karabiner-elements, sf-symbols, font-sf-mono, font-sf-pro, orbstack, localsend, intellij-idea, zed, google-drive, adobe-acrobat-reader, android-platform-tools, kde-connect |

## Flake-level Configuration (in `mkDarwin`, not in this module)
- Nix daemon binary is Lix (`nix.package` from shared `modules/common/nix-daemon.nix`); `nix.enable` is not set (Determinate Nix no longer used)
- `mac-app-util.darwinModules.default` — provides macOS application utilities via nix-darwin module
- `nix-homebrew.darwinModules.nix-homebrew` — installs and manages Homebrew
- `homebrew.autoMigrate = true`, `enableRosetta = true`

## Flow
`make darwin` → `nh darwin switch` → evaluates `darwinConfigurations."Sterling-MBP"` from flake → `mkDarwin` composes host module + shared modules + platform modules + flake-input modules → applies to nix-darwin → updates system.

## Integration
- **Imports**: `../../../modules/common` (nix-core, apps), `../../../modules/darwin` (system defaults, security), `./homebrew.nix`.
- **Consumer**: `nix/flake.nix`'s `mkDarwin` call with `hostname = "Sterling-MBP"`.
- **Home Manager**: Home Manager for Darwin runs via `home-manager-darwin` flake input, with configs from `nix/home/` and `nix/home/darwin/`.
- **Sketchybar/Aerospace**: GUI apps managed via Homebrew casks; their configs live outside Nix in the repo root (`sketchybar/`, `aerospace/`).
