# Repository Atlas: sirwayne/dotfiles

## Project Responsibility

Declarative, reproducible system configuration for two personal machines — **`Sterling-MBP`** (macOS / Darwin, `aarch64-darwin`) and **`kirby`** (NixOS, `x86_64-linux`) — built on Nix flakes with Home Manager. The repository also carries stow-able user configs for Neovim (LazyVim), the macOS status bar (sketchybar), a tiling window manager (AeroSpace), and the OpenCode agent/MCP runtime.

## System Entry Points

| Entry Point | Role |
|-------------|------|
| `nix/flake.nix` | Flake orchestrator. Declares the two active host outputs and the helper-function layer (`getStableNixpkgs`, `mkStablePkgs`, `mkSpecialArgs`, `mkHomeManagerConfig`, `mkSystem`, `mkDarwin`). |
| `nix/Makefile` | Build automation: `make darwin`, `make nixos`, `make update`, `make clean` (Tahoe `com.apple.macl` pre-prune + `nh clean all`), `make lint`, `make format`. Run from `nix/`. |
| `nix/flake.lock` | Pinned input manifest. |
| `.stowrc` | GNU Stow target (`~/.config`). Ignores `DS_Store`, `nix/`, `archive/`, `.stowrc`, and the two Nix-managed OpenCode files (`opencode/opencode.json`, `opencode/cli.json`) so the rest of `opencode/` stows cleanly. |
| `AGENTS.md` | Agent guidelines and architecture reference (authoritative for host/flake facts). |
| `sketchybar/sketchybarrc` | sketchybar bootstrap script (loads `helpers/` + `init.lua`). |
| `aerospace/aerospace.toml` | AeroSpace tiling WM config; launches sketchybar + borders on login. |
| `nvim/init.lua` | LazyVim entry; loads `lua/config/` and `lua/plugins/`. |
| `nix/home/ai/opencode.nix` | Source of truth for OpenCode v2 config. Generates `~/.config/opencode/opencode.json` and `~/.config/opencode/cli.json` at build time (both gitignored — not present in the repo). |
| `opencode/oh-my-opencode-slim.json` | Tracked OpenCode plugin config: presets and per-role sub-agent model assignments. |

## Active Hosts

Only two hosts are exported from `flake.nix`:

- **`Sterling-MBP`** — macOS (Darwin), `aarch64-darwin`. Uses Lix (`nix.package = pkgs.lixPackageSets.stable.lix` from the shared `modules/common/nix-daemon.nix`), `mac-app-util` (follows `nixpkgs-darwin`), nix-homebrew, and Home Manager (`home-manager-darwin`).
- **`kirby`** — NixOS, `x86_64-linux`. Secure boot via lanzaboote (pinned `v1.1.0`), Hyprland (lua config, built-in `dwindle` layout, `withUWSM = true`), KDE Plasma 6, `pkgs-stable` from `nixos-26.05`.

> **Hostname gotcha:** the `kirby` flake attribute passes `hostname = "kirby-machine"` to `mkSystem`. The `hostname` specialArg seen inside NixOS modules is `"kirby-machine"`; the flake attribute is `"kirby"`.

> **No orphaned host configs remain.** The former `hosts/nixos/wsl/`, `home/nixos/wsl/`, and `home/ubuntu/` trees have been **deleted from the working tree** (they are no longer present, not merely un-wired). Do not attempt to restore them without confirming with the user.

## Flake Architecture Highlights

- **Multiple nixpkgs inputs** per platform to avoid Darwin paying for NixOS tests: `nixpkgs` (`nixos-unstable`, used by NixOS), `nixpkgs-darwin` (`nixpkgs-unstable`, used by Darwin), `nixpkgs-stable-nixos` (`nixos-26.05`), `nixpkgs-stable-darwin` (`nixpkgs-26.05-darwin`).
- **`pkgs-stable`** is resolved per-system by `getStableNixpkgs`/`mkStablePkgs` and injected into `specialArgs` / `extraSpecialArgs` for all hosts.
- **Helper functions** in `flake.nix`: `mkSpecialArgs` (`inputs // { username, hostname, inputs, pkgs-stable } // extraArgs`), `mkHomeManagerConfig` (`useGlobalPkgs`/`useUserPackages`, `backupFileExtension = "backup"`), `mkSystem` (`nixosSystem` + home-manager module), `mkDarwin` (`darwinSystem` + mac-app-util + home-manager-darwin + nix-homebrew inline config).
- **Host wiring**:
  - `darwinConfigurations."Sterling-MBP"` → `mkDarwin` with `modules = [ ./hosts/darwin/Sterling-MBP ]` and `homeImports = [ ./home ./home/darwin mac-app-util.homeManagerModules.default ]`.
  - `nixosConfigurations."kirby"` → `mkSystem` with `modules = [ ./hosts/nixos/kirby lanzaboote.nixosModules.lanzaboote ]`, `homeImports = [ ./home ./home/nixos/kirby ]`, and `extraArgs = { zen-browser, llm-agents }`.
- **Input pinning / follow-edges**:
  - `nixpkgs` is **unpinned** and tracks `nixos-unstable` (the brief `e2587ca` pin was dropped 2026-08-29 once the ex-hy3 constraint was gone).
  - `darwin`, `mac-app-util`, and `home-manager-darwin` follow `nixpkgs-darwin`; `home-manager` and `lanzaboote` follow `nixpkgs`.
  - `lanzaboote` is pinned to tag `v1.1.0`.
  - **`typescript-language-server` overlay (kirby):** `hosts/nixos/kirby/default.nix` overrides `pnpmDeps` with the corrected hash from [nixpkgs#572951](https://github.com/NixOS/nixpkgs/pull/572951). Remove once `nixpkgs` advances past `eabfbbcf`.
  - **`debugpy` test-skip override (Darwin):** `home/neovim.nix` wraps `pkgs.python314Packages.debugpy` to append `test_add_code_to_python_process.py::test_lldb_command` to `disabledTestPaths` on Darwin — debugpy 1.8.22's bare-`lldb` assertion fails against nixpkgs' `hardcode-lldb.patch` store-path rewrite. Fixed upstream in [nixpkgs#572564](https://github.com/NixOS/nixpkgs/pull/572564) (merged 2026-10-11); remove once `nixpkgs-darwin` (`nixpkgs-unstable`) contains it.
  - **hy3 is gone.** The Hyprland plugin was removed 2026-08-29 in favour of Hyprland's built-in `dwindle` layout; the `hy3` flake input and extraArg no longer exist.
- **Lix on Darwin:** `nix.package = pkgs.lixPackageSets.stable.lix` in the shared `modules/common/nix-daemon.nix`; `nix.enable` is intentionally not set (the nix-darwin module does not manage the daemon). Determinate Nix is no longer used anywhere.

## Repository Directory Map (Aggregated)

| Directory | Responsibility Summary | Detailed Map |
|-----------|------------------------|--------------|
| `nix/` | Flake entry point, build automation, lint/format config; orchestrates both hosts via the helper-function layer. | [View Map](nix/codemap.md) |
| `nix/pkgs/` | Custom package derivations via `callPackage`. Currently only `unocss-language-server.nix` (the vendored `1password-cli` pin was removed). | [View Map](nix/pkgs/codemap.md) |
| `nix/home/` | Shared Home Manager profile root: zsh, neovim, yazi, git, oh-my-posh, tmux, packages, ai. Platform-conditional `homeDirectory`. | [View Map](nix/home/codemap.md) |
| `nix/home/ai/` | AI/agent Home Manager modules: `claude-code`, `opencode`, `antigravity-cli`, plus the MCP server registry. | [View Map](nix/home/ai/codemap.md) |
| `nix/home/darwin/` | Darwin Home Manager overlay: `ghostty-bin` override, `macos` oh-my-zsh plugin, audio tools, GUI apps, shared `modules/home/gui.nix`. | [View Map](nix/home/darwin/codemap.md) |
| `nix/home/nixos/` | NixOS Home Manager namespace (no `default.nix`); contains only `kirby/`. | [View Map](nix/home/nixos/codemap.md) |
| `nix/home/nixos/kirby/` | Kirby Home Manager config: Hyprland (lua, `dwindle`), ashell, rofi, swaync, theme, apps, packages, zen-browser, kde. | [View Map](nix/home/nixos/kirby/codemap.md) |
| `nix/hosts/` | Host system config namespace; dispatch happens in `flake.nix` via `mkDarwin`/`mkSystem`. | [View Map](nix/hosts/codemap.md) |
| `nix/hosts/darwin/` | Darwin host namespace; single active host `Sterling-MBP`. | [View Map](nix/hosts/darwin/codemap.md) |
| `nix/hosts/darwin/Sterling-MBP/` | Sterling-MBP macOS host: Lix, `mac-app-util`, homebrew taps/brews/casks, dock apps, user config. | [View Map](nix/hosts/darwin/Sterling-MBP/codemap.md) |
| `nix/hosts/nixos/` | NixOS host namespace; single host `kirby`. | [View Map](nix/hosts/nixos/codemap.md) |
| `nix/hosts/nixos/kirby/` | Kirby NixOS host: secure boot (lanzaboote), Hyprland, KDE Plasma 6, dnscrypt-proxy2, Tailscale, OpenRGB, Howdy, 10 submodules. | [View Map](nix/hosts/nixos/kirby/codemap.md) |
| `nix/modules/` | Reusable Nix modules root (no `default.nix`); platform-split: `common/`, `darwin/`, `home/`, `nixos/`. | [View Map](nix/modules/codemap.md) |
| `nix/modules/common/` | Cross-platform leaf modules: `apps.nix`, `nix-core.nix` (caches, fonts, zsh, CLI essentials), `nix-daemon.nix` (shared Lix/GC config). | [View Map](nix/modules/common/codemap.md) |
| `nix/modules/darwin/` | Darwin modules: pre-commit overlay from `pkgs-stable`, `nodejs-slim_24` libcxxStdenv rebuild, system defaults, dock, Touch ID (PAM), `insecure-packages.nix`; Darwin timer overlay on shared `nix-daemon.nix`. | [View Map](nix/modules/darwin/codemap.md) |
| `nix/modules/home/` | Shared Home Manager modules: `gui.nix` (Ghostty base config, TokyoNight theme) with host-override pattern. (No `default.nix` — dead aggregator removed.) | [View Map](nix/modules/home/codemap.md) |
| `nix/modules/nixos/` | NixOS leaf modules: podman, hyprland (nixpkgs), nix-ld, 1password, flatpak, localsend, `user-shell.nix`; NixOS timer overlay on shared `nix-daemon.nix`. | [View Map](nix/modules/nixos/codemap.md) |
| `nvim/` | LazyVim Neovim config root: `init.lua`, `stylua.toml`, `lazyvim.json` (36 extras), `lazy-lock.json` pinning. | [View Map](nvim/codemap.md) |
| `nvim/lua/` | Lua namespace root; auto-discovery via `require("lazy").setup({ spec = { { import = "plugins" } } })`. | [View Map](nvim/lua/codemap.md) |
| `nvim/lua/config/` | LazyVim config overrides: `lazy.lua` (bootstrap + spec wiring), `options.lua`, `keymaps.lua`, `autocmds.lua`. | [View Map](nvim/lua/config/codemap.md) |
| `nvim/lua/plugins/` | 11 plugin spec files (codecompanion, nixd, terraform, mason disable, etc.) using LazyVim spec fields. | [View Map](nvim/lua/plugins/codemap.md) |
| `sketchybar/` | macOS status bar root: bootstrap pipeline (sketchybarrc → helpers → init.lua → bar → items → event_loop), SbarLua Mach IPC. | [View Map](sketchybar/codemap.md) |
| `sketchybar/helpers/` | Bootstrap builder, external event-provider daemons (Mach IPC), menus.c, app_icons.lua lookup. | [View Map](sketchybar/helpers/codemap.md) |
| `sketchybar/items/` | Declarative bar items: apple, workspaces, front_app, calendar, media, widgets. Observer pattern via `item:subscribe()`. | [View Map](sketchybar/items/codemap.md) |
| `sketchybar/items/widgets/` | Provider-consumer widgets (battery, volume, wifi, cpu) with popup-details and mouse event wiring. | [View Map](sketchybar/items/widgets/codemap.md) |
| `aerospace/` | AeroSpace tiling WM config (`aerospace.toml`): binding modes, startup lifecycle (borders + sketchybar), workspace-to-monitor assignments, window rules. | [View Map](aerospace/codemap.md) |
| `opencode/` | OpenCode v2 agent runtime: `oh-my-opencode-slim.json` (presets + sub-agent roles), `settings.json` (empty placeholder), `skills/`, `.oh-my-opencode-slim/` bookkeeping. `opencode.json`/`cli.json` are Nix-generated and gitignored; there is **no local lockfile or install tree** — v2 installs plugin deps under `~/.cache/opencode/npm/<pkg>@latest/<ts>/node_modules`. | [View Map](opencode/codemap.md) |

### Untracked / Excluded Root Assets

These root directories exist but are excluded from codemap tracking (docs, archives, vendored caches) or are not code:

- `docs/` — issue-tracker, triage-label, and domain-doc agent references (`docs/agents/*`).
- `archive/`, `wallpapers/`, `claude/`, `.claude/`, `.github/`, `.idea/` — excluded via `exclude_patterns` or unsupported file types.

## Build & Validation Commands

All `make` targets run from `nix/`:

```bash
cd nix
make darwin    # nh darwin switch . -H Sterling-MBP
make nixos     # nh os switch . -H kirby
make update    # nix flake update
make clean     # prune stale .app bundles (Tahoe macl workaround), then nh clean all
make lint      # statix check .
make format    # nix fmt (nixfmt-tree)
```

Dry-run validation:

```bash
darwin-rebuild dry-run --flake .#Sterling-MBP
sudo nixos-rebuild dry-run --flake .#kirby
```

## Stow / Symlinking

`.stowrc` targets `~/.config`, ignores `DS_Store`, `nix/`, `archive/`, `.stowrc`, and the Nix-managed OpenCode files (`opencode/opencode.json`, `opencode/cli.json`). The `nvim/`, `sketchybar/`, `aerospace/`, and (remaining) `opencode/` content stow into `~/.config`.
