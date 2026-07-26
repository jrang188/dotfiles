# Repository Atlas: sirwayne/dotfiles

## Project Responsibility

Declarative, reproducible system configuration for two personal machines — **`Sterling-MBP`** (macOS / Darwin, aarch64) and **`kirby`** (NixOS, x86_64) — built on Nix flakes with Home Manager. The repository also carries stow-able user configs for Neovim (LazyVim), the macOS status bar (sketchybar), a tiling window manager (AeroSpace), and OpenCode agent/MCP settings.

## System Entry Points

| Entry Point | Role |
|-------------|------|
| `nix/flake.nix` | Flake orchestrator. Declares the two active host outputs and the helper-function layer (`mkSpecialArgs`, `mkStablePkgs`, `mkHomeManagerConfig`, `mkSystem`, `mkDarwin`). |
| `nix/Makefile` | Build automation: `make darwin`, `make nixos`, `make update`, `make clean`, `make lint`, `make format`. Run from `nix/`. |
| `nix/flake.lock` | Pinned input manifest. |
| `.stowrc` | Stow target (`~/.config`); ignores `nix/`, `archive/`, `.stowrc`. Drives symlinking of `nvim/`, `sketchybar/`, `aerospace/`. |
| `AGENTS.md` | Agent guidelines and repo architecture reference. |
| `sketchybar/sketchybarrc` | sketchybar bootstrap script (loads `helpers/` + `init.lua`). |
| `aerospace/aerospace.toml` | AeroSpace tiling WM config; launches sketchybar + borders on login. |
| `nvim/init.lua` | LazyVim entry; loads `lua/config/` and `lua/plugins/`. |
| `opencode/opencode.json` | OpenCode agent settings + MCP server registry (NixOS, Astro, Kubernetes, Pulumi). |

## Active Hosts

Only two hosts are exported from `flake.nix`:

- **`Sterling-MBP`** — macOS (Darwin), aarch64. Uses Lix (`nix.package = pkgs.lixPackageSets.stable.lix`), `mac-app-util` pinned independently, nix-homebrew, Home Manager (darwin branch).
- **`kirby`** — NixOS, x86_64. Secure boot via lanzaboote, Hyprland (pinned flake input) with hy3 plugin, KDE Plasma 6, autoUpgrade (commented), `pkgs-stable` from nixos-26.05.

> **Orphaned configs** (`hosts/nixos/wsl/`, `home/nixos/wsl/`, `home/ubuntu/`) exist in the tree but are **NOT exported** from `flake.nix`. Do not re-wire them without confirming with the user.

## Flake Architecture Highlights

- **Multiple nixpkgs inputs** per platform to avoid Darwin paying for NixOS tests: `nixpkgs` (nixos-unstable), `nixpkgs-darwin` (nixpkgs-unstable), `nixpkgs-stable-nixos`, `nixpkgs-stable-darwin`.
- **`pkgs-stable`** injected into `specialArgs` / `extraSpecialArgs` for all hosts via `mkSpecialArgs`.
- **Known pinning / overrides**: `mac-app-util` does NOT follow nixpkgs (SBCL 2.6.0 build failure); Hyprland pinned for `hy3` ABI compatibility; `lanzaboote` pinned to v1.1.0; Darwin `pre-commit` pulled from `pkgs-stable` (dotnet dependency issue); Darwin `nodejs-slim_24` rebuilt against `llvmPackages_20.libcxxStdenv` (V8 ODR with libc++ 21).
- **Helper functions** in `flake.nix`: `mkSpecialArgs`, `mkStablePkgs`, `mkHomeManagerConfig`, `mkSystem`, `mkDarwin`.

## Directory Map (Aggregated)

| Directory | Responsibility Summary | Detailed Map |
|-----------|------------------------|--------------|
| `nix/` | Flake entry point, build automation, lint/format config; orchestrates both hosts via helper functions. | [View Map](nix/codemap.md) |
| `nix/pkgs/` | Custom package derivations via `callPackage` (e.g. `unocss-language-server.nix`). Not overlays. | [View Map](nix/pkgs/codemap.md) |
| `nix/home/` | Shared Home Manager profile root: zsh, neovim, yazi, git, oh-my-posh, packages, ai. Platform-conditional `homeDirectory`. | [View Map](nix/home/codemap.md) |
| `nix/home/ai/` | AI/MCP Home Manager modules: `claude-code` (from llm-agents flake) + 4 MCP servers (nixos, astro, kubernetes, pulumi). | [View Map](nix/home/ai/codemap.md) |
| `nix/home/darwin/` | Darwin Home Manager overlay: ghostty-bin override, macos oh-my-zsh plugin, audio tools, shared `gui.nix`. | [View Map](nix/home/darwin/codemap.md) |
| `nix/home/nixos/` | NixOS Home Manager namespace (no `default.nix`); container for `kirby/` (active) and `wsl/` (orphaned). | [View Map](nix/home/nixos/codemap.md) |
| `nix/home/nixos/kirby/` | Kirby host Home Manager config: 9 submodules (theme, apps, packages, zen-browser, hyprland, rofi, ashell, swaync, kde), hy3 plugin, conditional theme. | [View Map](nix/home/nixos/kirby/codemap.md) |
| `nix/home/nixos/wsl/` | Orphaned WSL Home Manager config (ssh.exe bridge, Discord IPC relay). NOT wired into flake. | [View Map](nix/home/nixos/wsl/codemap.md) |
| `nix/home/ubuntu/` | Orphaned Ubuntu Home Manager config (ubuntu oh-my-zsh plugin, WSL bridge patterns). NOT wired into flake. | [View Map](nix/home/ubuntu/codemap.md) |
| `nix/hosts/` | Host system config namespace; dispatch happens in `flake.nix` via `mkDarwin`/`mkSystem`. | [View Map](nix/hosts/codemap.md) |
| `nix/hosts/darwin/` | Darwin host namespace; single active host `Sterling-MBP`. | [View Map](nix/hosts/darwin/codemap.md) |
| `nix/hosts/darwin/Sterling-MBP/` | Sterling-MBP macOS host: Determinate Nix, mac-app-util pinning, homebrew zap, dock apps, user config. | [View Map](nix/hosts/darwin/Sterling-MBP/codemap.md) |
| `nix/hosts/nixos/` | NixOS host namespace; `kirby/` (active) and `wsl/` (orphaned). | [View Map](nix/hosts/nixos/codemap.md) |
| `nix/hosts/nixos/kirby/` | Kirby NixOS host: secure boot (lanzaboote), Hyprland flake pin, KDE Plasma 6, dnscrypt-proxy2, OpenRGB, Howdy, 10 submodules. | [View Map](nix/hosts/nixos/kirby/codemap.md) |
| `nix/hosts/nixos/wsl/` | Orphaned WSL host config; only imports `modules/common`. NOT wired into flake. | [View Map](nix/hosts/nixos/wsl/codemap.md) |
| `nix/modules/` | Reusable Nix modules root (no `default.nix`); platform-split: `common/`, `darwin/`, `home/`, `nixos/`. | [View Map](nix/modules/codemap.md) |
| `nix/modules/common/` | Cross-platform leaf modules: `apps.nix`, `nix-core.nix` (Nix daemon tuning, caches, fonts, zsh, CLI essentials). | [View Map](nix/modules/common/codemap.md) |
| `nix/modules/darwin/` | Darwin modules: pre-commit overlay from `pkgs-stable`, `nodejs-slim_24` libcxxStdenv rebuild, system defaults, dock, Touch ID (PAM), Lix as Nix daemon. | [View Map](nix/modules/darwin/codemap.md) |
| `nix/modules/home/` | Shared Home Manager modules: `gui.nix` (Ghostty base config, TokyoNight theme) with host-override pattern. | [View Map](nix/modules/home/codemap.md) |
| `nix/modules/nixos/` | NixOS leaf modules: podman, hyprland (pinned flake), nix-ld, 1password, flatpak, localsend + inline GC config. | [View Map](nix/modules/nixos/codemap.md) |
| `nvim/` | LazyVim Neovim config root: `init.lua`, `stylua.toml`, `lazyvim.json` (36 extras), `lazy-lock.json` pinning. | [View Map](nvim/codemap.md) |
| `nvim/lua/` | Lua namespace root; auto-discovery via `require("lazy").setup({ spec = { { import = "plugins" } } })`. | [View Map](nvim/lua/codemap.md) |
| `nvim/lua/config/` | LazyVim config overrides: `lazy.lua` (bootstrap + spec wiring), `options.lua`, `keymaps.lua`, `autocmds.lua`. | [View Map](nvim/lua/config/codemap.md) |
| `nvim/lua/plugins/` | 10 plugin spec files (codecompanion, nixd, opencode, mason disable, etc.) using LazyVim spec fields. | [View Map](nvim/lua/plugins/codemap.md) |
| `sketchybar/` | macOS status bar root: bootstrap pipeline (sketchybarrc → helpers → init.lua → bar → items → event_loop), SbarLua Mach IPC. | [View Map](sketchybar/codemap.md) |
| `sketchybar/helpers/` | Bootstrap builder, external event-provider daemons (Mach IPC), menus.c, app_icons.lua lookup. | [View Map](sketchybar/helpers/codemap.md) |
| `sketchybar/items/` | Declarative bar items: apple, workspaces, front_app, calendar, media, widgets. Observer pattern via `item:subscribe()`. | [View Map](sketchybar/items/codemap.md) |
| `sketchybar/items/widgets/` | Provider-consumer widgets (battery, volume, wifi, cpu) with popup-details and mouse event wiring. | [View Map](sketchybar/items/widgets/codemap.md) |
| `aerospace/` | AeroSpace tiling WM config (`aerospace.toml`): binding modes, startup lifecycle (borders + sketchybar), workspace-to-monitor assignments, window rules. | [View Map](aerospace/codemap.md) |
| `opencode/` | OpenCode agent config: `opencode.json` (MCP registry, plugin pipeline), `oh-my-opencode-slim.json` (presets + sub-agent roles), `tui.json` (tokyonight), `skills/`. | [View Map](opencode/codemap.md) |

## Build & Validation Commands

All `make` targets run from `nix/`:

```bash
cd nix
make darwin    # nh darwin switch . -H Sterling-MBP
make nixos     # nh os switch . -H kirby
make update    # nix flake update
make clean     # nh clean all
make lint      # statix check .
make format    # nix fmt (also: make fmt)
```

Dry-run validation:

```bash
darwin-rebuild dry-run --flake .#Sterling-MBP
sudo nixos-rebuild dry-run --flake .#kirby
```

## Stow / Symlinking

`.stowrc` targets `~/.config` and ignores `nix/`, `archive/`, `.stowrc`. The `nvim/`, `sketchybar/`, and `aerospace/` directories stow into `~/.config`.