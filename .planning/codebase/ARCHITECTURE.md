---
title: Architecture
last_mapped: 2026-05-26
---

# Architecture

## Pattern

**Declarative multi-host Nix flake with shared Home Manager modules.**

The flake defines one output per host machine. Shared configuration is factored into Home Manager modules imported by every host. Platform-specific configuration is isolated to host directories and platform-specific module subtrees.

---

## Layered Module Hierarchy

```
flake.nix
├── darwinConfigurations."Sterling-MBP"
│   ├── modules/common/          ← Nix settings, caches, fonts, zsh
│   ├── modules/darwin/          ← macOS system defaults, security
│   └── hosts/darwin/Sterling-MBP/  ← hostname, dock, homebrew
│       └── home-manager (darwin) via home-manager-darwin
│           ├── home/            ← shared: zsh, neovim, git, packages, ai
│           └── home/darwin/     ← macOS: gui, packages, macos oh-my-zsh plugin
│
└── nixosConfigurations."kirby"
    ├── modules/common/          ← Nix settings, caches, fonts, zsh
    ├── modules/nixos/           ← NixOS-specific: flatpak, nix-ld, 1password, hyprland, podman, localsend
    └── hosts/nixos/kirby/       ← host config: boot, networking, desktop, hardware, secure-boot
        └── home-manager (nixos) via home-manager
            ├── home/            ← shared: zsh, neovim, git, packages, ai
            └── home/nixos/kirby/ ← hyprland, KDE, apps, rofi, swaync, theme, zen-browser
```

---

## Key Abstractions in flake.nix

Three helper functions eliminate boilerplate across host definitions (`nix/flake.nix:58-149`):

| Function | Purpose |
|---|---|
| `mkSpecialArgs` | Builds `specialArgs` with `username`, `hostname`, `inputs`, `pkgs-stable` |
| `mkHomeManagerConfig` | Wraps home-manager module with `useGlobalPkgs`, `useUserPackages`, extraSpecialArgs |
| `mkSystem` | Composes NixOS configuration: nixpkgs + determinate + home-manager + host modules |
| `mkDarwin` | Composes Darwin configuration: nix-darwin + mac-app-util + home-manager-darwin + host modules |

---

## Data Flow: How a host configuration is built

```
flake.nix
  └── mkDarwin / mkSystem
        ├── specialArgs → username, hostname, pkgs-stable, all inputs
        ├── system modules (modules/common, modules/darwin or modules/nixos, hosts/<host>)
        └── home-manager module
              └── home imports (home/, home/darwin or home/nixos/<host>)
```

All modules receive `specialArgs` via function arguments. Packages are sourced from `pkgs` (the host's primary nixpkgs) or `pkgs-stable` (host-appropriate stable nixpkgs).

---

## Module Boundaries

### `nix/modules/common/`
Applied to all hosts (Darwin + NixOS). Contains:
- `nix-core.nix` — Nix experimental features, binary caches, trusted keys, `allowUnfree`, `allowBroken`, fonts, zsh enable
- `apps.nix` — common system-level apps
- `default.nix` — imports the above

### `nix/modules/darwin/`
Darwin-only system modules:
- `system.nix` — macOS system defaults (dock, key repeat, activation scripts)
- `security.nix` — macOS security settings
- `default.nix` — imports the above

### `nix/modules/nixos/`
NixOS-only system modules: flatpak, nix-ld (foreign binary support), 1password, Hyprland, Podman, LocalSend.

### `nix/modules/home/`
Shared home-manager GUI modules (`gui.nix`).

### `nix/home/`
Home Manager user configuration shared across all systems:
- `default.nix` — root: imports zsh, neovim, git, oh-my-posh, packages, ai; sets `home.*`, `programs.home-manager`, `programs.nh`
- `zsh.nix` — shell config + oh-my-zsh
- `neovim.nix` — editor
- `git.nix` — version control
- `oh-my-posh.nix` — prompt theme
- `packages.nix` — shared packages + `programs.direnv`
- `ai/` — claude-code + MCP servers

### `nix/home/darwin/`
Darwin-specific home config (GUI apps, macOS oh-my-zsh plugin).

### `nix/home/nixos/kirby/`
kirby-specific home config (Hyprland, KDE, apps, swaync, rofi, theme, zen-browser).

---

## Entry Points

| Operation | Command | Entry File |
|---|---|---|
| Build macOS | `make darwin` → `nh darwin switch . -H Sterling-MBP` | `nix/flake.nix` → `darwinConfigurations."Sterling-MBP"` |
| Build NixOS kirby | `make nixos` → `nh os switch . -H kirby` | `nix/flake.nix` → `nixosConfigurations."kirby"` |
| Update inputs | `make update` → `nix flake update` | `nix/flake.lock` |
| Lint | `make lint` → `statix check .` | all `.nix` files |
| Format | `make format` → `nix fmt` | all `.nix` files via nixfmt |

---

## Auxiliary Configuration Directories

These live alongside `nix/` at the dotfiles root and are not managed by Nix directly:

| Directory | Purpose | Symlink Target |
|---|---|---|
| `opencode/` | OpenCode AI config (agents, skills, hooks, GSD) | `~/opencode` |
| `claude/` | Claude Code config (`settings.json`, `.gsd-profile`) | `~/.claude` (planned) |
| `nvim/` | Neovim/LazyVim Lua config | linked by Home Manager |
| `sketchybar/` | macOS status bar config | used directly |
| `aerospace/` | macOS tiling WM config | used directly |
| `wallpapers/` | Desktop wallpapers | referenced by hyprlock/hyprpaper |

---

## Missing Flake Outputs

Code exists for WSL (NixOS) and Ubuntu (home-manager) configurations but neither appears in `flake.nix` outputs:
- `nix/hosts/nixos/wsl/` — NixOS WSL host
- `nix/home/nixos/wsl/` — WSL home config
- `nix/home/ubuntu/` — Ubuntu home config

These are orphaned/incomplete.
