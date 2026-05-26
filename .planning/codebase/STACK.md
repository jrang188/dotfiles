# Technology Stack

**Analysis Date:** 2026-05-26

## Languages

**Primary:**
- **Nix** - System configuration language used throughout `nix/` for flakes, Home Manager modules, NixOS modules, Darwin modules, and package derivations
- **Lua** - Neovim configuration (`nvim/lua/`), Sketchybar configuration (`sketchybar/`)
- **TOML** - macOS tiling window manager config (`aerospace/aerospace.toml`)

**Secondary:**
- **Shell (Bash/Zsh)** - Helper scripts, `sketchybar/sketchybarrc`, opencode hooks (`opencode/hooks/*.sh`)
- **JavaScript (CommonJS)** - opencode hooks (`opencode/hooks/*.js`), runs under Node.js (`opencode/package.json`)
- **YAML** - `nix/.pre-commit-config.yaml`
- **JSON** - `opencode/*.json`, `nvim/lazyvim.json`, `nvim/lazy-lock.json`

## Runtime

**Environment:**
- **Nix** with flakes (managed by Determinate Nix on Darwin per `nix/modules/darwin/default.nix` and `nix/flake.nix` line 13)
- **Darwin (macOS)** - aarch64 (`Sterling-MBP` host)
- **NixOS** - x86_64 (`kirby` host)
- Orphaned/inactive: WSL (`nix/hosts/nixos/wsl/`), Ubuntu Home Manager (`nix/home/ubuntu/`)

**Nix Channels:**
- `nixpkgs` → `github:NixOS/nixpkgs/nixos-unstable` (NixOS)
- `nixpkgs-darwin` → `github:NixOS/nixpkgs/nixpkgs-unstable` (Darwin)
- `nixpkgs-stable-nixos` → `github:NixOS/nixpkgs/nixos-25.11`
- `nixpkgs-stable-darwin` → `github:NixOS/nixpkgs/nixpkgs-25.11-darwin`
- `nixpkgsHyprland` → pinned commit `dd9b079222d43e1943b6ebd802f04fd959dc8e61` (for hy3 compatibility)

**Package Manager:**
- **Nix** (primary, via flakes)
- **Homebrew** on Darwin (`nix/hosts/darwin/Sterling-MBP/homebrew.nix`) — manages GUI apps not available in nixpkgs
- **Flatpak** on NixOS (`nix/modules/nixos/flatpak.nix`)
- **`nh`** (Nix Helper) — primary rebuild command in `nix/Makefile`
- **`bun`** — opencode plugin lockfile (`opencode/bun.lock`)
- **`pnpm`/`yarn`/`npm`** — available via `nix/home/packages.nix` for JavaScript work

**Lockfiles:**
- `nix/flake.lock` — pinned flake inputs
- `nvim/lazy-lock.json` — Neovim plugins
- `opencode/bun.lock`, `opencode/package-lock.json` — opencode dependencies

## Frameworks

**Core:**
- **Nix Flakes** — entry point `nix/flake.nix`, declarative system composition
- **Home Manager** [`github:nix-community/home-manager`] — declarative user environment, applied via Darwin/NixOS modules
- **nix-darwin** [`github:LnL7/nix-darwin`] — macOS system management
- **Determinate Nix** [`https://flakehub.com/f/DeterminateSystems/determinate/*`] — Nix daemon replacement

**Neovim Framework:**
- **LazyVim** — declared in `nvim/lua/config/lazy.lua` and configured via `nvim/lazyvim.json` extras
- **lazy.nvim** — plugin manager, bootstrapped from `https://github.com/folke/lazy.nvim.git`

**Testing:**
- No formal test framework. Validation by `darwin-rebuild dry-run --flake .#Sterling-MBP` and `sudo nixos-rebuild dry-run --flake .#kirby` (documented in `CLAUDE.md`).

**Build/Dev:**
- **`make`** (`nix/Makefile`) — wraps `nh darwin switch`, `nh os switch`, `nix flake update`, `statix check`, `nix fmt`
- **`nh`** — Nix Helper for rebuilds and garbage collection
- **`pre-commit`** (`nix/.pre-commit-config.yaml`) — runs `treefmt`, `statix check`, whitespace/EOF/YAML/JSON hooks
- **`treefmt`** / **`nixfmt-tree`** — formatting
- **`statix`** — Nix linter

## Key Dependencies

**Flake Inputs (`nix/flake.nix`):**
- `nixpkgs`, `nixpkgs-darwin`, `nixpkgs-stable-nixos`, `nixpkgs-stable-darwin` — package sets
- `determinate` — Determinate Systems Nix
- `darwin` [LnL7/nix-darwin] — Darwin system module
- `mac-app-util` [hraban/mac-app-util] — macOS .app trampolining (NOT following nixpkgs to avoid SBCL 2.6.0 build failure, see `nix/flake.nix` lines 19-23)
- `home-manager`, `home-manager-darwin` — split inputs per platform
- `zen-browser` [`github:0xc000022070/zen-browser-flake`] — Zen browser (kirby)
- `lanzaboote` [`github:nix-community/lanzaboote/v1.0.0`] — Secure Boot for kirby
- `nixpkgsHyprland` — pinned nixpkgs commit for Hyprland 0.53.3 (hy3 plugin compatibility)
- `llm-agents` [`github:numtide/llm-agents.nix`] — provides `opencode` and `claude-code` packages

**Critical Programming Toolchains (`nix/home/packages.nix`):**
- `nodejs`, `bun`, `pnpm`, `yarn-berry` — JavaScript ecosystem
- `python3`, `uv` — Python
- `go` — Go
- `rustup` — Rust toolchain installer
- `temurin-bin.jdk-21`, `gradle`, `maven`, `spring-boot-cli` — Java
- `nil`, `nixd`, `nixfmt`, `nixfmt-tree`, `statix` — Nix tooling

**LSPs/Formatters/DAP (`nix/home/neovim.nix`):**
- LSPs: `astro-language-server`, `basedpyright`, `docker-compose-language-service`, `dockerfile-language-server`, `gopls`, `helm-ls`, `jdt-language-server`, `kotlin-language-server`, `marksman`, `nixd`, `pyright`, `ruff`, `rust-analyzer`, `sqls`, `tailwindcss-language-server`, `taplo`, `unocss-language-server` (custom pkg `nix/pkgs/unocss-language-server.nix`), `terraform-ls`, `typescript-language-server`, `vtsls`, `vue-language-server`, `yaml-language-server`, `vscode-langservers-extracted`
- Formatters: `prettierd`, `stylua`, `shfmt`
- Linters: `shellcheck`, `python314Packages.flake8`, `markdownlint-cli2`, `markdown-toc`
- DAP: `delve`, `python314Packages.debugpy`

**DevOps/Cloud (`nix/home/packages.nix`):**
- `tenv` (Terraform), `kubernetes-helm`, `kubectl`, `kubectx`, `k9s`, `kind`, `minikube`, `talosctl`
- `awscli2`, `google-cloud-sdk`, `oci-cli`
- `pulumi-bin`, `pulumi-esc`
- `podman-tui`, `lazydocker`
- `act` (local GitHub Actions runner)

**CLI Utilities:**
- `gh` (GitHub CLI), `stripe-cli`, `_1password-cli`, `codecrafters-cli`, `devenv`, `devbox`, `pre-commit`
- `jq`, `fzf`, `fd`, `ripgrep`, `bat`, `tree`, `lazygit`, `stow`, `tmux`, `cachix`

## Configuration

**Environment:**
- Username and hostname injected via `specialArgs` and `extraSpecialArgs` from `nix/flake.nix` helper `mkSpecialArgs` (lines 66-77)
- Time zone: `America/Vancouver` (`nix/hosts/nixos/kirby/default.nix`)
- Locale: `en_CA.UTF-8` (kirby)
- Home Manager `stateVersion = "24.11"` (`nix/home/default.nix`)
- NixOS `stateVersion = "25.05"` (kirby), `"24.05"` (orphaned WSL host)
- Darwin `system.stateVersion = 5` (`nix/modules/darwin/system.nix`)

**Build:**
- `nix/flake.nix` — entry point, defines `darwinConfigurations."Sterling-MBP"` and `nixosConfigurations."kirby"`
- `nix/Makefile` — build wrappers (`make darwin`, `make nixos`, `make update`, `make clean`, `make lint`, `make format`)
- `nix/.editorconfig` — 2-space indent for Nix files
- `nix/.pre-commit-config.yaml` — pre-commit hooks
- `nvim/stylua.toml` — Lua formatter (2 spaces, 120 columns)
- `.stowrc` — GNU Stow config targeting `~/.config`, ignoring `nix/`, `archive/`, `.stowrc`

**Nix Substituters (`nix/modules/common/nix-core.nix`):**
- `https://nix-community.cachix.org/`
- `https://cachix.cachix.org`
- `https://hyprland.cachix.org`
- `https://ghostty.cachix.org`
- `https://devenv.cachix.org`
- `https://cache.numtide.com`

**Allowed unfree/broken:** `nixpkgs.config.allowUnfree = true; allowBroken = true;` in `nix/modules/common/nix-core.nix` and `nix/modules/darwin/default.nix`.

**Fonts (`nix/modules/common/nix-core.nix`, `nix/modules/darwin/system.nix`):**
- `nerd-fonts.fira-code`, `nerd-fonts.jetbrains-mono`, `font-awesome`, `sketchybar-app-font`

## Platform Requirements

**Development:**
- macOS aarch64 (Apple Silicon) for `Sterling-MBP`
- x86_64 Linux for `kirby`
- Determinate Nix installed (Darwin)
- For first-time setup: `nh`, `darwin-rebuild`, or `nixos-rebuild` available

**Production / Deployed System:**
- macOS Darwin (`Sterling-MBP`): aarch64-darwin
- NixOS (`kirby`): x86_64-linux with Secure Boot via `lanzaboote`, KDE Plasma 6 + SDDM (`nix/hosts/nixos/kirby/desktop.nix`), Hyprland + hy3 plugin (`nix/home/nixos/kirby/hyprland.nix`)
- Audio: PipeWire (kirby)
- Container runtime: Podman with Docker compatibility shim (`nix/modules/nixos/podman.nix`)

---

*Stack analysis: 2026-05-26*
