# AGENTS.md - Agent Guidelines for This Repository

Nix-based system configurations for macOS (Darwin) and NixOS. Uses Nix flakes with Home Manager for declarative, reproducible system configuration.

## Repository Map

A full codemap is available at `codemap.md` in the project root.

Before working on any task, read `codemap.md` to understand:
- Project architecture and entry points
- Directory responsibilities and design patterns
- Data flow and integration points between modules

For deep work on a specific folder, also read that folder's `codemap.md`.

## Repository Structure

```
├── nix/                    # Main Nix configuration
│   ├── flake.nix           # Flake entry point (helper fns: mkSpecialArgs, mkStablePkgs, mkHomeManagerConfig, mkSystem, mkDarwin)
│   ├── Makefile            # Build commands
│   ├── home/               # Home Manager configs (shared + host-specific)
│   ├── hosts/              # Host-specific system configs
│   ├── modules/            # Reusable Nix modules (common/, darwin/, home/, nixos/)
│   └── pkgs/               # Custom package derivations (callPackage)
├── nvim/                   # Neovim configuration (LazyVim-based)
│   ├── lua/                # Lua plugins and config
│   └── stylua.toml         # Lua formatter config
├── sketchybar/             # macOS status bar config (Lua-based)
├── aerospace/              # macOS tiling window manager config
└── opencode/               # OpenCode agent configuration
```

## Active Hosts

Only two hosts are wired in `flake.nix` outputs:

- **`Sterling-MBP`** — macOS (Darwin), aarch64
- **`kirby`** — NixOS, x86_64

> **Hostname gotcha:** the `kirby` flake output passes `hostname = "kirby-machine"` to `mkSystem` (not `"kirby"`). The `hostname` specialArg seen inside NixOS modules is `"kirby-machine"`; the flake attribute is `"kirby"`.

> **Note:** WSL (`hosts/nixos/wsl/`, `home/nixos/wsl/`, `home/ubuntu/`) and Ubuntu home configs exist in the tree but are **not currently exported** from `flake.nix`. They are orphaned configs left over from prior iterations.

## Build Commands

All `make` targets must be run from the `nix/` directory:

```bash
cd nix

make darwin   # Rebuild Sterling-MBP via `nh darwin switch`
make nixos    # Rebuild kirby via `nh os switch`
make update   # Update flake inputs (`nix flake update`)
make clean    # Garbage collect (`nh clean all`)
make lint     # Lint with statix
make format   # Format with nixfmt-tree (`nix fmt`)
```

### Manual rebuilds (when `nh` is unavailable)

```bash
# macOS
darwin-rebuild switch --flake .#Sterling-MBP

# NixOS
sudo nixos-rebuild switch --flake .#kirby
```

### Validation / dry-run

```bash
# macOS
darwin-rebuild dry-run --flake .#Sterling-MBP

# NixOS
sudo nixos-rebuild dry-run --flake .#kirby
```

## Format and Lint

```bash
cd nix

# Format all Nix files (uses flake formatter output)
nix fmt

# Lint (statix)
make lint
statix check .

# Pre-commit hooks (install once)
pre-commit install
pre-commit run --all-files
```

## Code Style

### Nix

- **Indentation**: 2 spaces (enforced by `nix/.editorconfig`)
- **Formatter**: `nixfmt` via `nix fmt`
- **Linter**: `statix`
- **Line width**: No strict limit; keep reasonable
- **Attribute ordering**: Group related attributes together

### Nix Expression Conventions

```nix
# Prefer function shorthand for simple arguments
{ username, pkgs, ... }:

# Use let bindings for intermediate values
let
  inherit (pkgs) foo bar;
  derivedValue = foo + bar;
in

{
  # Group related options
  imports = [ ./foo.nix ./bar.nix ];

  home = {
    inherit username;
    stateVersion = "24.11";
  };
}
```

### Package Lists

Use category headers and `with pkgs;`:

```nix
home.packages = with pkgs; [
  # ============================================
  # Category Name
  # ============================================
  package1
  package2
];
```

### Import Order

In `default.nix` files, prefer this order:

1. Shared modules (top-level `./module.nix`)
2. Platform modules (`./darwin/`, `./nixos/`)
3. Host modules (`./nixos/kirby/`)

### Conditional Logic

Use `lib.mkIf`, `lib.mkMerge`, and `lib.mkDefault` instead of `if then else`:

```nix
services.foo.enable = pkgs.stdenv.hostPlatform.isLinux;

programs.zsh.initExtra = lib.mkMerge [
  (lib.mkIf cfg.enablePlugin1 ''...'')
  (lib.mkIf cfg.enablePlugin2 ''...'')
];
```

## Neovim Configuration (`nvim/`)

- **Framework**: LazyVim
- **Language**: Lua
- **Formatter**: stylua (`stylua.toml`: 2 spaces, 120 columns)
- **Plugin specs**: `lua/plugins/*.lua`
- **Config overrides**: `lua/config/*.lua`
- **Extras**: See `lazyvim.json` for enabled language/formatting extras

Format Lua:
```bash
cd nvim
stylua lua/
```

## macOS Configs (sketchybar, aerospace)

- **`sketchybar/`**: Lua-based status bar. Entry point is `sketchybarrc`, which loads `helpers/` and `init.lua`.
- **`aerospace/`**: Tiling window manager config in `aerospace.toml`. Starts `sketchybar` and `borders` on launch.

## Flake Architecture Notes

### Multiple nixpkgs Inputs

The flake uses **separate nixpkgs inputs** per platform to avoid Darwin paying the cost of NixOS tests:

- `nixpkgs` → `nixos-unstable` (used by NixOS)
- `nixpkgs-darwin` → `nixpkgs-unstable` (used by Darwin)
- `nixpkgs-stable-nixos` → `nixos-26.05`
- `nixpkgs-stable-darwin` → `nixpkgs-26.05-darwin`

`pkgs-stable` is injected into `specialArgs` / `extraSpecialArgs` for all hosts via `mkStablePkgs` (dispatches to the correct stable channel by `system`).

### Known Pinning / Overrides

- **`mac-app-util` follows `nixpkgs-darwin`** — the previously independent pin (to avoid SBCL 2.6.0 build failures) was removed 2026-07 after [hraban/mac-app-util#42](https://github.com/hraban/mac-app-util/issues/42) was closed as cannot-repro.
- **hy3 pinned to upstream `hl0.56.0.1`** on `kirby` because nixpkgs' `hyprlandPlugins.hy3` lags one minor behind the matching Hyprland ABI (0.55.0 vs Hyprland 0.56.0). The upstream hy3 is built against the same source as nixpkgs' hyprland (both pull from `github:hyprwm/Hyprland?ref=v0.56.0`), so the C++ ABI matches. When nixpkgs catches up to hy3 0.56.x, drop the upstream pin and use `pkgs.hyprlandPlugins.hy3` directly.
- **hyprlang config deprecation (FOLLOW-UP NEEDED):** as of Hyprland 0.55 the `.conf` config format is deprecated in favor of `hyprland.lua`. The repo still uses `configType = "hyprlang"` in `home/nixos/kirby/hyprland.nix:7` and is on `home.stateVersion = "24.11"` (which defaults to hyprlang). Works fine on 0.56 because home-manager only writes `hyprland.conf` (never both files), so Hyprland loads it as hyprlang. The maintainer stated hyprlang will be supported for "1–2 releases starting from 0.22" — removal expected in 0.57 or 0.58. **Before the next Hyprland major bump, migrate to Lua**: change `configType` to `"lua"` and rewrite `home/nixos/kirby/hyprland.nix` (settings table + `extraConfig` `plugin { hy3 { } }` block) to Lua. Also bump `home.stateVersion` to `26.05` in `home/nixos/kirby/default.nix` so home-manager's default flips to `"lua"`. Tracked as a separate todo.
- **Lix on Darwin** — `nix.package = pkgs.lixPackageSets.stable.lix` replaces the Nix daemon binary; `nix.enable` is not set in Darwin modules (the nix-darwin module does not manage the daemon). Determinate Nix is no longer used.

### Helper Functions in `flake.nix`

- `mkSpecialArgs` — builds `specialArgs` with `username`, `hostname`, `inputs`, `pkgs-stable`
- `mkStablePkgs` — resolves the correct stable nixpkgs legacyPackages by `system` (via `getStableNixpkgs`)
- `mkHomeManagerConfig` — creates a Home Manager user config with `extraSpecialArgs`
- `mkSystem` — creates a `nixosSystem`
- `mkDarwin` — creates a `darwinSystem`

### Auto-Upgrade

`system.autoUpgrade` is currently **commented out** in `hosts/nixos/kirby/default.nix`. The commented block (if re-enabled) updates `nixpkgs` and `nixpkgs-darwin` every Monday and Thursday at 04:00, then rebuilds from `/home/sirwayne/dotfiles/nix#kirby`.

## Pre-Commit Setup

Pre-commit hooks are configured in `nix/.pre-commit-config.yaml`:

- `treefmt` — formats Nix files
- `statix check .` — lints Nix files
- `trailing-whitespace`, `end-of-file-fixer` — general hygiene
- `check-yaml`, `check-json` — syntax validation

Install once:
```bash
cd nix
pre-commit install
```

## Stow / Dotfiles Symlinking

`.stowrc` targets `~/.config` and ignores `nix/`, `archive/`, and `.stowrc`. The `nvim/`, `sketchybar/`, and `aerospace/` directories are intended to be stowed into `~/.config`.

## AI / MCP Configuration

- `opencode/opencode.json` — OpenCode agent settings and MCP server registry (NixOS, Astro, Kubernetes, Pulumi).
- `nix/home/ai/` — Home Manager modules for `claude-code` and `mcp` servers.

## Useful Nix Commands

```bash
# Evaluate config (NixOS)
nix eval .#nixosConfigurations.kirby.config.system.build.toplevel

# Show differences between generations
nix diff ./result /run/current-system

# Search for packages
nix search nixpkgs package-name

# Collect garbage
nix-store --gc
```

## General Principles

1. **Test before committing**: Always run `make lint` and `make format` from `nix/`.
2. **Modularize**: Create separate files for distinct concerns.
3. **Document host-specifics**: Add comments for non-obvious configurations.
4. **Use flakes**: All active configurations use the flake-based setup.
5. **Follow the structure**: Place files in appropriate directories per the project structure.
6. **Do not expand orphaned configs**: WSL/Ubuntu configs exist but are not wired up; do not add them back without confirming with the user.

## Known Issues

### macOS Tahoe (26.x): `com.apple.macl` blocks `nix-collect-garbage`

**Root cause:** When Ghostty (or any GUI app launched from `/nix/store/...`) runs, macOS stamps the `com.apple.macl` extended attribute on every file inside the `.app` bundle. On macOS 26.x (Tahoe), this xattr is **TCC-protected** — not even root can strip it with `xattr -d` (confirmed: all nested files return `EPERM`). `nix-collect-garbage` calls `chmod -R +w` on stale store paths before deleting them; the chmod hits EPERM on every macl'd file, and the entire GC aborts with "0 store paths deleted".

**The old workaround (`sudo xattr -dr com.apple.macl ...`) is permanently broken on Tahoe.** Do not re-add it. The Makefile `clean:` target now handles this via a pre-clean step that discovers all `.app` bundles in the nix store, queries `nix-store --query --referrers` for each, and `sudo rm -rf`s any with zero non-self referrers. Root can unlink entries from `/nix/store` without chmod'ing the files (unlink only needs write-perm on the parent dir, not the file), which sidesteps the SACL entirely.

**Recurrence:** Every `make darwin` cycle produces a new `ghostty-bin` hash. Once it becomes stale and has been launched, it retains macl and blocks GC. The pre-clean step handles this automatically on every `make clean`.

**Do NOT:**
- Replace the `clean:` target with `xattr -dr com.apple.macl` — permanently broken on Tahoe.
- Use `2>/dev/null || true` to mask GC failures — the root cause is deterministic, not transient.
- Attempt to strip `com.apple.macl` with any `xattr` variant — blocked by TCC on macOS 26.x.

## Agent skills

### Issue tracker

GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Default labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — `CONTEXT.md` + `docs/adr/` at repo root. See `docs/agents/domain.md`.
