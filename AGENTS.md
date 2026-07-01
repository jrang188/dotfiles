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
.
├── nix/                    # Main Nix configuration
│   ├── flake.nix           # Flake entry point
│   ├── Makefile            # Build commands
│   ├── home/               # Home Manager configs (shared + host-specific)
│   ├── hosts/              # Host-specific system configs
│   ├── modules/            # Reusable Nix modules
│   └── lib/                # Helper functions (currently empty)
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
make format   # Format with nixfmt (also: `make fmt`)
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
- `nixpkgs-stable-nixos` / `nixpkgs-stable-darwin` → stable release branches

`pkgs-stable` is injected into `specialArgs` / `extraSpecialArgs` for all hosts.

### Known Pinning / Overrides

- **`mac-app-util` does NOT follow nixpkgs** — pinned separately to avoid SBCL 2.6.0 build failure ([hraban/mac-app-util#42](https://github.com/hraban/mac-app-util/issues/42)).
- **Hyprland pinned to 0.53.3** on `kirby` via `nixpkgsHyprland` overlay — required for `hy3` compatibility. Remove once `hy3` supports Hyprland 0.54.x.
- **Darwin pre-commit from stable** — overlay pulls `pre-commit` from `pkgs-stable` to avoid a `dotnet` dependency issue ([NixOS/nixpkgs#450554](https://github.com/NixOS/nixpkgs/issues/450554)).
- **Determinate Nix on Darwin** — `nix.enable = false` in Darwin modules because Determinate Nix manages the daemon.

### Helper Functions in `flake.nix`

- `mkSpecialArgs` — builds `specialArgs` with `username`, `hostname`, `inputs`, `pkgs-stable`
- `mkHomeManagerConfig` — creates a Home Manager user config with `extraSpecialArgs`
- `mkSystem` — creates a `nixosSystem`
- `mkDarwin` — creates a `darwinSystem`

### Auto-Upgrade

`kirby` has `system.autoUpgrade` enabled. It updates `nixpkgs` and `nixpkgs-darwin` inputs every Monday and Thursday at 04:00, then rebuilds from `/home/sirwayne/dotfiles/nix#kirby`.

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
