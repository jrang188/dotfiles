<!-- refreshed: 2026-05-26 -->
# Architecture

**Analysis Date:** 2026-05-26

## System Overview

```text
┌─────────────────────────────────────────────────────────────────┐
│                  Flake Entry (`nix/flake.nix`)                  │
│  Inputs: nixpkgs, nix-darwin, home-manager, lanzaboote, etc.    │
│  Outputs: darwinConfigurations.*, nixosConfigurations.*         │
│  Helpers: mkSystem, mkDarwin, mkHomeManagerConfig, mkSpecialArgs│
└────────────┬───────────────────────────────────┬────────────────┘
             │                                   │
             ▼                                   ▼
┌────────────────────────────┐   ┌──────────────────────────────────┐
│   Host Configurations      │   │   Home Manager (per-user)        │
│   `nix/hosts/`             │   │   `nix/home/`                    │
│  - darwin/Sterling-MBP/    │   │  - default.nix (shared)          │
│  - nixos/kirby/            │   │  - darwin/ (macOS overlay)       │
│  - nixos/wsl/              │   │  - nixos/kirby/ (Linux desktop)  │
│  (system-level options,    │   │  - nixos/wsl/ (WSL overrides)    │
│   hostname, users, boot)   │   │  - ubuntu/ (HM-only)             │
└──────────┬─────────────────┘   └──────────────┬───────────────────┘
           │ imports                            │ imports
           ▼                                    ▼
┌─────────────────────────────────────────────────────────────────┐
│              Reusable Modules (`nix/modules/`)                  │
│  - common/    → cross-platform system options + apps + nix core │
│  - darwin/    → nix-darwin system/security/system.nix           │
│  - nixos/     → hyprland, podman, 1password, nix-ld, flatpak    │
│  - home/      → shared HM modules (gui/ghostty)                 │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│              Generated System Closure (`/run/current-system`)   │
│              Activated via: nh / nixos-rebuild / darwin-rebuild │
└─────────────────────────────────────────────────────────────────┘

Adjacent (not Nix-managed at runtime, but symlinked via stow):
- `nvim/`        → LazyVim Lua config (loaded by Neovim from XDG)
- `sketchybar/`  → Lua-driven macOS status bar (sbar event loop)
- `aerospace/`   → aerospace.toml tiling WM config
- `opencode/`    → opencode IDE/agent configuration (separate ecosystem)
```

## Component Responsibilities

| Component | Responsibility | File |
|-----------|----------------|------|
| Flake entry | Declares inputs, builds all system/darwin configurations, wires home-manager | `nix/flake.nix` |
| `mkSystem` helper | Builds NixOS configurations with home-manager attached | `nix/flake.nix` (lines 99-122) |
| `mkDarwin` helper | Builds nix-darwin configurations with mac-app-util + HM | `nix/flake.nix` (lines 125-149) |
| `mkHomeManagerConfig` | Injects home-manager into system module list | `nix/flake.nix` (lines 80-96) |
| `mkSpecialArgs` | Threads `username`, `hostname`, `pkgs-stable`, inputs through modules | `nix/flake.nix` (lines 67-77) |
| Darwin host | macOS host options (dock, hostname, homebrew) | `nix/hosts/darwin/Sterling-MBP/default.nix` |
| NixOS host (kirby) | Linux desktop host (boot, hardware, networking, secure-boot) | `nix/hosts/nixos/kirby/default.nix` |
| WSL host | WSL-specific NixOS overrides | `nix/hosts/nixos/wsl/default.nix` |
| Shared HM | Cross-platform user environment (zsh, neovim, git, packages) | `nix/home/default.nix` |
| Darwin HM | macOS user overlays (ghostty-bin, gui overrides) | `nix/home/darwin/default.nix` |
| Kirby HM | Linux desktop user environment (hyprland, rofi, ashell) | `nix/home/nixos/kirby/default.nix` |
| Common modules | Cross-platform system bits (nix settings, packages) | `nix/modules/common/` |
| Darwin modules | nix-darwin defaults (system, security) | `nix/modules/darwin/` |
| NixOS modules | NixOS feature modules (hyprland, podman, 1password) | `nix/modules/nixos/` |
| Home modules | Reusable HM modules (gui/ghostty) | `nix/modules/home/` |
| Custom packages | Locally-defined Nix packages | `nix/pkgs/` |
| Makefile | High-level build targets (`make darwin`, `make nixos`) | `nix/Makefile` |
| Neovim config | LazyVim plugin spec + custom plugins | `nvim/init.lua`, `nvim/lua/` |
| Sketchybar config | Lua status bar items + helpers | `nvim/sketchybarrc`, `sketchybar/` |
| stow config | Drives symlinking of non-Nix dotfiles to `~/.config` | `.stowrc` |

## Pattern Overview

**Overall:** Layered Nix flake with three-tier composition (Host → Module → Home).

**Key Characteristics:**
- **Declarative, reproducible:** All system/user state derives from `nix/flake.nix` and the immutable input pins in `nix/flake.lock`.
- **Multi-target from one flake:** A single flake produces `darwinConfigurations."Sterling-MBP"` (aarch64-darwin) and `nixosConfigurations."kirby"` (x86_64-linux). WSL/Ubuntu host configs are present but not currently wired as outputs.
- **Three layers per host:** *host* (machine identity + hardware), *modules* (reusable feature toggles), *home* (per-user environment via Home Manager imported as a system module).
- **Platform-split nixpkgs inputs:** Darwin uses `nixpkgs-darwin` (no NixOS tests, faster cache hits); Linux uses `nixpkgs`. Stable channels (`nixpkgs-stable-darwin`, `nixpkgs-stable-nixos`) are exposed as `pkgs-stable` via `specialArgs` for selective pinning.
- **Determinate Nix:** `inputs.determinate` is applied to NixOS hosts (system-wide). On Darwin, the built-in `nix.enable = false` is set so Determinate's installer-managed daemon owns nix.
- **Overlay-based pinning:** `nix/hosts/nixos/kirby/default.nix` overlays `hyprland`/`hyprlandPlugins` from `nixpkgsHyprland` (pinned commit) to keep `hy3` working. `nix/modules/darwin/default.nix` overlays `pre-commit` from stable to dodge a dotnet build failure.
- **No `nix/lib/`:** The `lib/` directory exists but is empty; helper functions live inline in `flake.nix` (`mkSystem`, `mkDarwin`, `mkHomeManagerConfig`, `mkSpecialArgs`, `mkStablePkgs`, `getStableNixpkgs`).
- **Non-Nix dotfiles via stow:** `.stowrc` targets `~/.config` and explicitly ignores `nix/` and `archive/`; runtime configs for `nvim/`, `sketchybar/`, `aerospace/`, `opencode/` are symlinked, not evaluated by Nix.

## Layers

**Flake (top):**
- Purpose: Entry point; declares external inputs and assembles configurations
- Location: `nix/flake.nix`, `nix/flake.lock`
- Contains: input URLs, helper functions, output attribute sets
- Depends on: External flake registries (github:NixOS/nixpkgs, etc.)
- Used by: `nh`, `darwin-rebuild`, `nixos-rebuild`, `home-manager`

**Host configurations:**
- Purpose: Per-machine system settings (boot, hardware, networking, hostname, users)
- Location: `nix/hosts/darwin/<host>/`, `nix/hosts/nixos/<host>/`
- Contains: `default.nix` (entry), optional `homebrew.nix`/`boot.nix`/`hardware.nix`/etc.
- Depends on: `../../../modules/common`, `../../../modules/<platform>`, sibling host files
- Used by: `mkSystem` / `mkDarwin` invocations in `flake.nix`

**Reusable modules:**
- Purpose: Composable system-level feature units (hyprland, podman, 1password, gui)
- Location: `nix/modules/common/`, `nix/modules/darwin/`, `nix/modules/nixos/`, `nix/modules/home/`
- Contains: One file per concern, plus a `default.nix` that imports siblings
- Depends on: `pkgs`, `pkgs-stable`, `lib`, sometimes `inputs`
- Used by: Host configs (system modules) and home configs (HM modules)

**Home Manager (user):**
- Purpose: Per-user environment — shell, editor, git, dotfiles, user packages
- Location: `nix/home/`
- Contains: `default.nix` (shared imports), platform overlays (`darwin/`, `nixos/<host>/`, `ubuntu/`), and feature files (`zsh.nix`, `neovim.nix`, `git.nix`, `packages.nix`, `oh-my-posh.nix`, `ai/`)
- Depends on: `pkgs`, `inputs`, `username`, `hostname`
- Used by: `mkHomeManagerConfig` (mounted under `home-manager.users.${username}.imports`)

**Adjacent (non-Nix runtime configs):**
- Purpose: Tool configs consumed directly at runtime (not by `nix build`)
- Location: `nvim/`, `sketchybar/`, `aerospace/`, `opencode/`, `wallpapers/`
- Contains: Lua, TOML, JSON, Markdown — language-specific config formats
- Symlinked via: GNU stow (see `.stowrc`)

## Data Flow

### Primary Rebuild Path (Darwin)

1. `make darwin` runs `nh darwin switch . -H Sterling-MBP` (`nix/Makefile:14`)
2. `nh` invokes nix-darwin with `darwinConfigurations."Sterling-MBP"` from `nix/flake.nix:153`
3. `mkDarwin` resolves `specialArgs` (`username`, `hostname`, `inputs`, `pkgs-stable`) via `mkSpecialArgs` (`nix/flake.nix:67`)
4. Host modules import: `./hosts/darwin/Sterling-MBP` (which imports `../../../modules/common`, `../../../modules/darwin`, `./homebrew.nix`)
5. `mac-app-util.darwinModules.default` + `home-manager-darwin.darwinModules.home-manager` are added (`nix/flake.nix:141-147`)
6. `mkHomeManagerConfig` mounts `./home`, `./home/darwin`, and `mac-app-util.homeManagerModules.default` under `home-manager.users.sirwayne.imports`
7. nix-darwin evaluates the full module tree, builds the system closure, and activates it (dock, brews, fonts, etc.)

### Primary Rebuild Path (NixOS)

1. `make nixos` runs `nh os switch . -H kirby` (`nix/Makefile:17`)
2. `nh` invokes nixos-rebuild with `nixosConfigurations."kirby"` from `nix/flake.nix:164`
3. `mkSystem` builds the configuration with `hostname = "kirby-machine"`, `system = "x86_64-linux"`, and `extraArgs = { zen-browser; llm-agents; }`
4. Host modules import: `./hosts/nixos/kirby` (boot, hardware-configuration, networking, desktop, openrgb, howdy, secure-boot, packages, hyprland overlay) plus `inputs.lanzaboote.nixosModules.lanzaboote`
5. Determinate + home-manager modules are added (`nix/flake.nix:111-120`)
6. `mkHomeManagerConfig` mounts `./home` + `./home/nixos/kirby` for the user
7. NixOS evaluates, builds, activates (systemd-boot via lanzaboote, hyprland session, etc.)

### Module Resolution

1. A `default.nix` in any directory acts as the import barrel for that subtree
2. Each module receives `{ config, pkgs, lib, username, hostname, inputs, pkgs-stable, ... }` from `specialArgs`
3. Options set across modules are merged by Nix's module system (`lib.mkIf`, `lib.mkMerge`, `lib.mkDefault` for conditionals and overrides)
4. Cross-tree imports use relative paths (`../../../modules/common`)

**State Management:**
- All state is derived purely from inputs and module evaluation; the resulting derivation is symlinked at `/run/current-system` (Linux) or `/run/current-system` analog on Darwin
- `flake.lock` pins every input commit for full reproducibility
- `nh` handles activation, garbage collection (weekly, `--keep-since 4d --keep 3`), and channel cleanup (`nix/home/default.nix:43-50`)

## Key Abstractions

**Flake helper (`mkSystem` / `mkDarwin`):**
- Purpose: Factory functions that hide boilerplate of wiring `nixpkgs.lib.nixosSystem` / `darwin.lib.darwinSystem` with home-manager
- Examples: `nix/flake.nix:99` (`mkSystem`), `nix/flake.nix:125` (`mkDarwin`)
- Pattern: Builder function taking `{ hostname, system?, modules, homeImports, extraArgs? }`

**Special args injection (`mkSpecialArgs`):**
- Purpose: Threads `username`, `hostname`, `inputs`, `pkgs-stable` (system-specific stable channel) into every module
- Examples: `nix/flake.nix:67`
- Pattern: All modules can destructure these from their function argument; e.g. `{ username, hostname, pkgs, pkgs-stable, ... }:`

**Barrel `default.nix`:**
- Purpose: Conventional aggregation file that imports every sibling module in a directory
- Examples: `nix/modules/common/default.nix`, `nix/modules/nixos/default.nix`, `nix/home/default.nix`, `nix/home/ai/default.nix`
- Pattern: `{ imports = [ ./foo.nix ./bar.nix ./subdir ]; }`

**Platform branching via stdenv:**
- Purpose: Decide values based on host platform without separate hosts files
- Examples: `nix/home/default.nix:3-10` (homeDirectory varies by `pkgs.stdenv.hostPlatform.system`)
- Pattern: `if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then ... else ...`

**Overlay pinning:**
- Purpose: Use a specific package version from another nixpkgs input without changing the rest of the channel
- Examples: `nix/hosts/nixos/kirby/default.nix:16-23` (hyprland from `nixpkgsHyprland`), `nix/modules/darwin/default.nix:15-19` (pre-commit from stable)
- Pattern: `nixpkgs.overlays = [ (final: prev: { inherit (other-input.legacyPackages.${system}) pkgName; }) ];`

**Custom package via `callPackage`:**
- Purpose: Define a local derivation outside nixpkgs
- Examples: `nix/home/neovim.nix:3` calls `pkgs.callPackage ../pkgs/unocss-language-server.nix { }`
- Pattern: Drop a `.nix` file in `nix/pkgs/`, then `pkgs.callPackage` it from the consumer

## Entry Points

**Flake outputs:**
- Location: `nix/flake.nix:152-181`
- Triggers: `darwin-rebuild`, `nixos-rebuild`, `nh` reading the flake URI + attribute
- Responsibilities: Expose `darwinConfigurations."Sterling-MBP"`, `nixosConfigurations."kirby"`, and `formatter.<system>`

**Makefile targets:**
- Location: `nix/Makefile`
- Triggers: Developer runs `make darwin`, `make nixos`, `make update`, `make lint`, `make format`, `make clean`
- Responsibilities: Wrap `nh`, `nix flake update`, `statix check`, `nix fmt`, garbage collection

**Neovim entry:**
- Location: `nvim/init.lua`
- Triggers: Neovim startup reading from `~/.config/nvim` (stow-symlinked)
- Responsibilities: `require("config.lazy")` to bootstrap lazy.nvim, LazyVim, and plugin spec

**Sketchybar entry:**
- Location: `sketchybar/sketchybarrc`
- Triggers: `sketchybar` daemon (installed via homebrew) reads `~/.config/sketchybar/sketchybarrc`
- Responsibilities: Loads `helpers` + `init` (which sets up bars, items, widgets) and runs `sbar.event_loop()`

## Architectural Constraints

- **Threading:** Nix evaluation is single-process; `nix.settings.eval-cores = 0` (`nix/modules/nixos/default.nix:21`) lets it use all available cores during evaluation. Sketchybar runs its own Lua event loop (`sketchybar/init.lua:16`).
- **Global state:** `username = "sirwayne"` and system strings (`darwinSystem = "aarch64-darwin"`, `nixosSystem = "x86_64-linux"`) are defined once at the top of `flake.nix` and threaded via `specialArgs`. There is no mutable runtime state — everything is a pure function of `flake.lock` + module code.
- **Circular imports:** None observed. Modules import in one direction (host → modules/home), and barrel `default.nix` files only import siblings.
- **Single-user assumption:** The entire system assumes user `sirwayne`. Adding a second user would require parameterizing or duplicating the home-manager mount in `mkHomeManagerConfig`.
- **Determinate vs nixpkgs nix:** On Darwin `nix.enable = false` is required (`nix/flake.nix:140`) because Determinate manages its own daemon. Don't enable `programs.nix` features there without checking.
- **Pinned hyprland:** Bumping `inputs.nixpkgsHyprland` is constrained by `hy3` compatibility (`nix/hosts/nixos/kirby/default.nix:42-44`). Lift the pin only after verifying hy3 supports the new hyprland version.
- **Ubuntu/WSL outputs are absent:** `nix/home/ubuntu/` and `nix/hosts/nixos/wsl/` files exist but no corresponding `homeConfigurations.sirwayne` or `nixosConfigurations.wsl` output is wired in `flake.nix`. `make wsl` / `make ubuntu` are documented in `CLAUDE.md` but the corresponding Makefile targets are not present.
- **Stow target conflicts:** `.stowrc` targets `~/.config` for everything but the Nix tree; collisions with home-manager-managed config files (e.g. `ghostty`) would silently break activation.
- **`nix/lib/` empty:** Despite being referenced in `CLAUDE.md` as "Helper functions," the directory contains no files. All helpers are inline in `flake.nix`.

## Anti-Patterns

### Inlining helper functions instead of using `nix/lib/`

**What happens:** `mkSystem`, `mkDarwin`, `mkHomeManagerConfig`, `mkSpecialArgs`, `mkStablePkgs`, `getStableNixpkgs` all live inside `let ... in` in `nix/flake.nix` (~70 lines of boilerplate at the top of the file).
**Why it's wrong:** `flake.nix` should be a thin manifest of outputs; mixing helper logic with output declarations makes both harder to read and prevents reuse from sibling tooling.
**Do this instead:** Move helpers into `nix/lib/default.nix` (the directory already exists) and import via `lib = import ./lib { inherit inputs; };`. Reference: `flake.nix:51-149`.

### Multiple `nixpkgs.config` declarations

**What happens:** `allowUnfree = true` and `allowBroken = true` are set in both `nix/modules/common/nix-core.nix:29-32` and `nix/modules/darwin/default.nix:8-11`.
**Why it's wrong:** Redundant; both modules are imported on Darwin so the option is asserted twice. Eventually one drifts.
**Do this instead:** Set `nixpkgs.config` once in `nix/modules/common/nix-core.nix` and remove the duplicate from `nix/modules/darwin/default.nix`.

### Per-host WSL/Ubuntu logic not wired to outputs

**What happens:** `nix/hosts/nixos/wsl/default.nix` and `nix/home/ubuntu/default.nix` define complete configurations, but `flake.nix` exposes no `nixosConfigurations.wsl` or `homeConfigurations.sirwayne` output, and the Makefile has no `wsl`/`ubuntu` targets.
**Why it's wrong:** Dead code drifts. New contributors (or future-you) cannot tell whether these are aspirational or actively used.
**Do this instead:** Either delete them, or add `mkSystem { hostname = "wsl"; modules = [./hosts/nixos/wsl]; ... }` and a `homeConfigurations` builder for Ubuntu, plus matching `wsl:` / `ubuntu:` Makefile targets.

### Mixing stow-managed dotfiles with home-manager-managed configs

**What happens:** Ghostty is configured via home-manager (`nix/modules/home/gui.nix`) but `aerospace/` and `sketchybar/` are stow-symlinked from the repo root. Inconsistent ownership means some tools' configs are reproducible via rebuild and others aren't.
**Why it's wrong:** Splits the "source of truth" surface. Onboarding a fresh machine requires both `make darwin` *and* a `stow` step; forgetting either yields a broken environment.
**Do this instead:** Move stow-managed configs into home-manager via `xdg.configFile."aerospace/aerospace.toml".source = ./aerospace/aerospace.toml;` (or equivalent). Drop `.stowrc` once migration is complete.

## Error Handling

**Strategy:** Errors surface at evaluation time (Nix) or activation time (system switch). There is no runtime error handling — the configuration either evaluates to a valid system closure or fails the build.

**Patterns:**
- Pre-commit hooks (`statix check`, `treefmt`) catch syntax/style issues before commit (`CLAUDE.md:74-79`)
- `make lint` and `make format` provide manual checks (`nix/Makefile:25-29`)
- Dry-run via `nixos-rebuild dry-run --flake .#kirby` validates without activating (`CLAUDE.md:86-90`)
- `nh` shows a diff of the new closure before activation
- `nix flake update` followed by build catches input regressions early

## Cross-Cutting Concerns

**Logging:** Build/activation logs go to stdout via `nh`/`nixos-rebuild`/`darwin-rebuild`. There is no centralized logging configured. Sketchybar Lua errors surface in macOS Console.app.

**Validation:** `statix` lint + `nixfmt` formatting are the only pre-commit static checks. There is no test framework; validation = successful build (`CLAUDE.md:81-91`).

**Authentication:** Trust list managed via `nix.settings.trusted-users = [ username ]` per-host. Cachix substituters and their public keys are declared in `nix/modules/common/nix-core.nix:9-26`.

**Garbage collection:** `nh` clean runs weekly with `--keep-since 4d --keep 3 --optimise` (`nix/home/default.nix:45-49`). NixOS hosts also enable `nix.gc.automatic` daily with `--delete-older-than 7d` (`nix/modules/nixos/default.nix:11-22`).

**Secrets:** No secrets management is wired in the flake (no agenix/sops). Git config has `signing.format = null;` (`nix/home/git.nix:15`) so commits are unsigned. Howdy (face auth) is enabled on kirby via `nix/hosts/nixos/kirby/howdy.nix`.

---

*Architecture analysis: 2026-05-26*
