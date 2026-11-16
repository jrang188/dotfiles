# dotfiles

Declarative, reproducible system configuration for two personal machines — **`Sterling-MBP`** (macOS / Darwin, aarch64) and **`kirby`** (NixOS, x86_64) — built on [Nix flakes](https://nixos.wiki/wiki/Flakes) with [Home Manager](https://github.com/nix-community/home-manager). The repository also carries stow-able user configs for Neovim (LazyVim), the macOS status bar (sketchybar), a tiling window manager (AeroSpace), and OpenCode agent/MCP settings.

## Layout

| Path | Responsibility |
|------|----------------|
| `nix/` | Flake entry point, build automation, lint/format; orchestrates both hosts |
| `nix/home/` | Home Manager profiles (shared + host-specific) |
| `nix/hosts/` | Host system configs (`Sterling-MBP`, `kirby`) |
| `nix/modules/` | Reusable Nix modules (`common/`, `darwin/`, `nixos/`, `home/`) |
| `nix/pkgs/` | Custom package derivations via `callPackage` |
| `nvim/` | Neovim config (LazyVim) |
| `sketchybar/` | macOS status bar config (Lua) |
| `opencode/` | OpenCode agent config and skills |
| `codemap.md` | Full repository atlas |

Only two hosts are exported from `flake.nix`: **`Sterling-MBP`** (Darwin, aarch64) and **`kirby`** (NixOS, x86_64). Legacy WSL / Ubuntu configs remain in the tree but are **not wired up**.

## Requirements

- [Nix](https://nixos.org/download.html) (flakes enabled)
- For macOS: [nix-darwin](https://github.com/LnL7/nix-darwin) and [Home Manager](https://github.com/nix-community/home-manager) (both come in as flake inputs)
- [`nh`](https://github.com/viperML/nh) (used by the justfile; optional if you use the manual commands)
- [`just`](https://github.com/casey/just) (command runner; installed by this repo's Home Manager config)

## Building

All recipes are defined in the root `justfile` and can be run from the repo root or any subdirectory — they always execute in `nix/`:

```bash
just darwin   # rebuild Sterling-MBP (nh darwin switch)
just nixos    # rebuild kirby (nh os switch)
just update   # update flake inputs (nix flake update)
just clean    # garbage collect (prune dead .app-bearing store paths, then nh clean all)
just lint     # lint with statix
just format   # format with nixfmt-tree (nix fmt)
just          # list available recipes
```

Manual rebuilds (when `nh` is unavailable):

```bash
# macOS
darwin-rebuild switch --flake .#Sterling-MBP

# NixOS
sudo nixos-rebuild switch --flake .#kirby
```

Validation / dry-run:

```bash
darwin-rebuild dry-run --flake .#Sterling-MBP   # macOS
sudo nixos-rebuild dry-run --flake .#kirby       # NixOS
```

## Stow / symlinking

`.stowrc` targets `~/.config` and ignores `nix/`, `archive/`, and `.stowrc`. Only `nvim/` is stowed:

```bash
stow nvim
```

`sketchybar/` is no longer stowed — Home Manager links it to `~/.config/sketchybar` (`xdg.configFile."sketchybar"`, an out-of-store symlink back into this repo), so no manual step is needed.

## Flake architecture

The flake uses **separate nixpkgs inputs per platform** so Darwin doesn't pay for NixOS tests:

- `nixpkgs` → `nixos-unstable` (NixOS)
- `nixpkgs-darwin` → `nixpkgs-unstable` (Darwin)
- `nixpkgs-stable-nixos` → `nixos-26.05`
- `nixpkgs-stable-darwin` → `nixpkgs-26.05-darwin`

`pkgs-stable` is injected into `specialArgs` / `extraSpecialArgs` for all hosts. Helper functions live in `nix/flake.nix`: `mkSpecialArgs`, `mkStablePkgs`, `mkHomeManagerConfig`, `mkSystem`, `mkDarwin`.

## Code quality

```bash
just lint      # statix check .
just format    # nix fmt
```

Pre-commit hooks are configured (format Nix, lint, hygiene, YAML/JSON validation). Install once with `pre-commit install`.

## Notes

- **macOS Tahoe GC workaround**: `just clean` includes a pre-clean step that removes dead store paths carrying `.app` bundles, so GC never has to chmod a `com.apple.macl` file. See the Known Issues section of `AGENTS.md` — do not replace it with `xattr` stripping, which is permanently broken on macOS 26.x.
- **Hyprland config migration**: `kirby` uses the deprecated hyprlang config format; see `AGENTS.md` for the follow-up Lua migration before the next Hyprland major bump.

## Documentation

- `AGENTS.md` — agent guidelines and repo architecture reference
- `codemap.md` — full repository atlas (with per-directory `codemap.md` files)
