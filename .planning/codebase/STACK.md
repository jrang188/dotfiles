---
title: Technology Stack
last_mapped: 2026-05-26
---

# Technology Stack

## Primary Language

**Nix** — all system, home-manager, and package configuration is written in Nix expressions (`.nix` files). No other language is used for system configuration.

**Secondary languages (tooling / auxiliary config):**
- **Lua** — Neovim plugin configuration (`nvim/lua/`)
- **Bash / Zsh** — hook scripts, Makefile targets, zsh init content
- **JavaScript (CJS)** — GSD runtime hooks in `opencode/hooks/` and `claude/` (Node.js, CommonJS)

---

## Core Framework

| Layer | Tool | Version / Channel |
|---|---|---|
| Package manager | Nix (Determinate Systems) | Flakes-enabled |
| NixOS modules | nixpkgs | `nixos-unstable` |
| macOS modules | nixpkgs-darwin | `nixpkgs-unstable` |
| Stable fallback (NixOS) | nixpkgs-stable-nixos | `nixos-25.11` |
| Stable fallback (Darwin) | nixpkgs-stable-darwin | `nixpkgs-25.11-darwin` |
| macOS system config | nix-darwin | `github:LnL7/nix-darwin` |
| User environment | Home Manager | follows nixpkgs / nixpkgs-darwin |
| Secure boot | lanzaboote | `v1.0.0` |
| Rebuild helper | nh | via nixpkgs |

---

## Flake Inputs

All inputs are in `nix/flake.nix`:

| Input | Source | Notes |
|---|---|---|
| `nixpkgs` | `github:NixOS/nixpkgs/nixos-unstable` | NixOS primary |
| `nixpkgs-darwin` | `github:NixOS/nixpkgs/nixpkgs-unstable` | macOS primary |
| `nixpkgs-stable-nixos` | `github:NixOS/nixpkgs/nixos-25.11` | Stable reference |
| `nixpkgs-stable-darwin` | `github:NixOS/nixpkgs/nixpkgs-25.11-darwin` | Stable reference |
| `determinate` | `flakehub.com/f/DeterminateSystems/determinate/*` | Determinate Nix |
| `darwin` | `github:LnL7/nix-darwin` | follows nixpkgs-darwin |
| `home-manager` | `github:nix-community/home-manager` | follows nixpkgs |
| `home-manager-darwin` | `github:nix-community/home-manager` | follows nixpkgs-darwin |
| `mac-app-util` | `github:hraban/mac-app-util` | **does NOT follow nixpkgs** (SBCL 2.6.0 workaround) |
| `zen-browser` | `github:0xc000022070/zen-browser-flake` | NixOS only |
| `lanzaboote` | `github:nix-community/lanzaboote/v1.0.0` | follows nixpkgs |
| `nixpkgsHyprland` | `github:NixOS/nixpkgs/dd9b079...` | **Pinned commit** — hyprland 0.53.3 for hy3 compat |
| `llm-agents` | `github:numtide/llm-agents.nix` | opencode + claude-code packages |

---

## Shell Environment

- **Shell:** Zsh (managed by Home Manager `programs.zsh`)
- **Framework:** oh-my-zsh with plugins: `git`, `fnm`, `bun`, `kubectl`, `helm`, `terraform`, `aws`, `uv`, `direnv`, `macos` (Darwin only)
- **Enhancements:** syntax highlighting, autosuggestion
- **PATH additions:** `$HOME/.local/bin`, `$GOPATH/bin`, `/usr/local/go/bin`

---

## Installed Packages (shared across all hosts)

Defined in `nix/home/packages.nix`:

### Nix & Editor Tools
- `nil`, `nixd` — dual Nix LSPs
- `nixfmt`, `nixfmt-tree`, `statix` — formatting and linting

### General Utilities
`jq`, `fzf`, `fd`, `ripgrep`, `bat`, `tree`, `stow`, `openssl`, `lazygit`, `tmux`, `cachix`, `xxd`

### Programming Languages & Runtimes
`nodejs`, `uv`, `python3`, `go`, `bun`, `rustup`, `temurin-bin.jdk-21`, `gradle`, `maven`

### Development Tools
`gh`, `stripe-cli`, `_1password-cli`, `gnumake`, `golangci-lint`, `spring-boot-cli`, `pre-commit`, `devenv`, `devbox`, `pnpm`, `yarn-berry`, `codecrafters-cli`

### DevOps & Cloud
`tenv` (Terraform), `kubernetes-helm`, `kubectl`, `kubectx`, `k9s`, `awscli2`, `google-cloud-sdk`, `oci-cli`, `pulumi-bin`, `pulumi-esc`, `podman-tui`, `lazydocker`, `kind`, `minikube`, `talosctl`

### AI Tools (via llm-agents.nix)
`opencode`, `claude-code`

---

## macOS-Specific (Homebrew, via nix-darwin)

Defined in `nix/hosts/darwin/Sterling-MBP/homebrew.nix`. Managed declaratively with `cleanup = "zap"` on activation.

**Brews:** `sketchybar`, `borders`, `lua`, `kafka`, `mole`, `media-control`, `scrcpy`

**Casks:** `raycast`, `scroll-reverser`, `warp`, `aerospace`, `karabiner-elements`, `sf-symbols`, `font-sf-mono`, `font-sf-pro`, `orbstack`, `localsend`, `kdeconnect`, `intellij-idea`, `zed`, `google-drive`, `adobe-acrobat-reader`, `android-platform-tools`

---

## Fonts

| Font | Source |
|---|---|
| Fira Code Nerd Font | nixpkgs `nerd-fonts.fira-code` |
| JetBrains Mono Nerd Font | nixpkgs `nerd-fonts.jetbrains-mono` |
| Font Awesome | nixpkgs `font-awesome` |
| Sketchybar App Font | nixpkgs `sketchybar-app-font` (Darwin) |
| SF Symbols, SF Mono, SF Pro | Homebrew casks (Darwin) |

---

## Neovim

- **Base:** LazyVim (see `nvim/lazyvim.json`)
- **Config language:** Lua
- **Formatter:** stylua (`nvim/stylua.toml`) — 2-space indent, 120 col width
- **Nix integration:** `programs.neovim` via Home Manager (`nix/home/neovim.nix`)

---

## NixOS Desktop (kirby)

- **Window manager:** Hyprland (pinned 0.53.3) + hy3 tiling plugin
- **Session manager:** KDE Plasma (also installed — dual desktop)
- **Notification daemon:** swaync
- **App launcher:** Rofi
- **Screen lock:** hyprlock / hypridle
- **Wallpaper daemon:** hyprpaper
- **Blue light filter:** hyprsunset
- **Status bar:** ashell

---

## Binary Caches

Configured in `nix/modules/common/nix-core.nix`:

| Cache | URL |
|---|---|
| nix-community | `https://nix-community.cachix.org/` |
| cachix | `https://cachix.cachix.org` |
| hyprland | `https://hyprland.cachix.org` |
| ghostty | `https://ghostty.cachix.org` |
| devenv | `https://devenv.cachix.org` |
| numtide | `https://cache.numtide.com` |
