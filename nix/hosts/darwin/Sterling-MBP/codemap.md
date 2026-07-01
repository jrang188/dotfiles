# nix/hosts/darwin/Sterling-MBP/

## Responsibility
Host-specific nix-darwin module for the **Sterling-MBP** machine (Apple Silicon MacBook Pro, `aarch64-darwin`). Defines the macOS system-level configuration: host identity, user account, Docker dock pinned applications, and Homebrew-managed packages that complement the Nix package set.

## Design
- **Module pattern**: A standard Nix module accepting `{ pkgs, username, hostname, ... }` from the flake's `specialArgs`.
- **Composition over inheritance**: Imports three layers — shared modules (`../../../modules/common`), Darwin platform modules (`../../../modules/darwin`), and this host's `./homebrew.nix`.
- **Mixed package management**: Combines Nix-managed packages (via shared/darwin modules) with Homebrew-managed GUI apps and CLI tools (via `nix-homebrew` flake input, configured in `flake.nix`). Homebrew `onActivation.cleanup = "zap"` ensures only listed formulae/casks remain installed.
- **Determinate Nix integration**: `nix.enable = false` is set in `flake.nix`'s `mkDarwin` (not here), deferring Nix daemon management to Determinate Nix.
- **mac-app-util pinning**: The `mac-app-util` flake input is pinned independently (does not follow nixpkgs) to avoid SBCL 2.6.0 build failures. Its Darwin module and Home Manager module are imported in `mkDarwin`.

## Files
| File | Role |
|------|------|
| `default.nix` | Host module entry point. Imports shared/Darwin modules, sets `networking.hostName`, `networking.computerName`, `users.users.sirwayne`, `nix.settings.trusted-users`, and `system.defaults.dock.persistent-apps`. |
| `homebrew.nix` | Homebrew configuration: enables Homebrew, sets `onActivation.upgrade = true` and `onActivation.cleanup = "zap"`, defines `taps`, `brews`, and `casks` for GUI apps and CLI tools not in nixpkgs. |

## Key Configuration Options
| Option | Value / Effect |
|--------|---------------|
| `networking.hostName` | `"Sterling-MBP"` (from flake's `hostname` arg) |
| `networking.computerName` | `"Sterling-MBP"` |
| `users.users.sirwayne.home` | `"/Users/sirwayne"` |
| `nix.settings.trusted-users` | `[ "sirwayne" ]` |
| `system.defaults.dock.persistent-apps` | Ordered list of 12 apps (Zen Browser, Ghostty, Zed, VS Code, IntelliJ IDEA, OpenCode, Claude, Antigravity, Obsidian, Discord, Spotify, System Settings) |
| `homebrew.enable` | `true` |
| `homebrew.onActivation.cleanup` | `"zap"` — uninstalls unlisted formulae/casks |
| `homebrew.taps` | `nikitabobko/tap`, `FelixKratz/formulae`, `homebrew/services`, `grishka/grishka` |
| `homebrew.brews` | sketchybar, borders, lua, kafka, mole, media-control, scrcpy |
| `homebrew.casks` | raycast, scroll-reverser, warp, aerospace, karabiner-elements, sf-symbols, fonts, orbstack, localsend, intellij-idea, zed, google-drive, adobe-acrobat-reader, android-platform-tools |

## Flake-level Configuration (in `mkDarwin`, not in this module)
- `nix.enable = false` (Determinate Nix manages the daemon)
- `mac-app-util.darwinModules.default` — provides macOS application utilities via nix-darwin module
- `nix-homebrew.darwinModules.nix-homebrew` — installs and manages Homebrew
- `homebrew.autoMigrate = true`, `enableRosetta = true`
- Darwin pre-commit pinned via overlay in `modules/darwin/default.nix`: pulls `pre-commit` from `pkgs-stable` to avoid dotnet dependency ([NixOS/nixpkgs#450554](https://github.com/NixOS/nixpkgs/issues/450554))

## Flow
`make darwin` → `nh darwin switch` → evaluates `darwinConfigurations."Sterling-MBP"` from flake → `mkDarwin` composes host module + shared modules + platform modules + flake-input modules → applies to nix-darwin → updates system.

## Integration
- **Imports**: `../../../modules/common` (nix-core, apps), `../../../modules/darwin` (system defaults, security), `./homebrew.nix`.
- **Consumer**: `nix/flake.nix`'s `mkDarwin` call with `hostname = "Sterling-MBP"`.
- **Home Manager**: Home Manager for Darwin runs via `home-manager-darwin` flake input, with configs from `nix/home/` and `nix/home/darwin/`.
- **Sketchybar/Aerospace**: GUI apps managed via Homebrew casks; their configs live outside Nix in the repo root (`sketchybar/`, `aerospace/`).
