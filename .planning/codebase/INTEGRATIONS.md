---
title: External Integrations
last_mapped: 2026-05-26
---

# External Integrations

## MCP Servers (Claude Code / OpenCode)

Defined in `nix/home/ai/mcp.nix` — managed via `programs.mcp`:

| Server | Type | Command / URL | Purpose |
|---|---|---|---|
| `nixos` | local | `uvx mcp-nixos` | NixOS/nixpkgs package and option search |
| `astro` | remote | `https://mcp.docs.astro.build/mcp` | Astro framework documentation |
| `kubernetes` | local | `npx -y kubernetes-mcp-server@latest` | Kubernetes cluster management |
| `pulumi` | remote | `https://mcp.ai.pulumi.com/mcp` | Pulumi IaC assistance |

---

## AI Tools

| Tool | Source | Config Location |
|---|---|---|
| Claude Code | `llm-agents.nix` (numtide) | `~/dotfiles/claude/` (symlinked `~/.claude`) |
| OpenCode | `llm-agents.nix` (numtide) | `~/opencode/` (symlinked) |

**Claude Code plugins** (marketplace, from `claude/settings.json`):
- `superpowers@superpowers-marketplace` — `github:obra/superpowers-marketplace`
- `terraform-module-generation@hashicorp` — `github:hashicorp/agent-skills`
- `terraform-skill@antonbabenko` — `github:antonbabenko/terraform-skill`
- `fullstack-dev-skills@fullstack-dev-skills` — `github:jeffallan/claude-skills`
- `claude-plugins-official` — `github:anthropics/claude-plugins-official`

---

## Version Control

- **Git:** managed via Home Manager `programs.git` (`nix/home/git.nix`)
- **Identity:** Justin Ang `<justinang177@gmail.com>`
- **Defaults:** `init.defaultBranch = main`, `push.autoSetupRemote = true`, `pull.ff = only`
- **LFS:** enabled
- **GitHub CLI:** `gh` installed via nixpkgs

---

## Cloud Providers

All CLIs installed via nixpkgs in `nix/home/packages.nix`:

| Provider | CLI Tool |
|---|---|
| AWS | `awscli2` |
| Google Cloud | `google-cloud-sdk` |
| Oracle Cloud | `oci-cli` |
| Pulumi (IaC) | `pulumi-bin`, `pulumi-esc` |

---

## Package Managers & Registries

| Manager | Purpose | Notes |
|---|---|---|
| Homebrew | macOS GUI apps | Managed declaratively via nix-darwin; `cleanup = "zap"` removes unlisted packages |
| Nix binary caches | Pre-built packages | cachix, hyprland, ghostty, devenv, numtide, nix-community |
| FlakeHub | Determinate Nix | `flakehub.com/f/DeterminateSystems/determinate/*` |
| npm / npx | MCP server runtime | `kubernetes-mcp-server@latest` fetched at runtime |

---

## Security / Auth

| Integration | Tool | Notes |
|---|---|---|
| 1Password | `_1password-cli` (nixpkgs), `1password` (NixOS module) | Used for secrets management |
| Facial recognition | howdy (`nix/hosts/nixos/kirby/howdy.nix`) | Linux IR camera login |
| Secure boot | lanzaboote v1.0.0 | kirby NixOS only |
| DNSCrypt | Configured in kirby networking | Minisign public key hardcoded in config |

---

## Dotfile Management

- **Stow:** installed via nixpkgs; `.stowrc` sets `--target=~/.config`
- **Manual symlinks:** `~/opencode → ~/dotfiles/opencode`, `~/.claude → ~/dotfiles/claude` (planned)
- **Direnv:** `programs.direnv` with `nix-direnv` for per-project Nix shells

---

## Sketchybar (macOS status bar)

- Config in `sketchybar/`
- Installed via Homebrew (`brew install sketchybar`)
- Zsh hook triggers `sketchybar --trigger brew_update` on `brew upgrade/update/outdated`
- `sketchybar-app-font` installed via nixpkgs

---

## KDE Connect

- NixOS: `programs.kdeconnect.enable = true` in `nix/hosts/nixos/kirby/default.nix`
- macOS: installed via Homebrew cask (`kdeconnect`)
- Autostarted via Hyprland: `kdeconnect-indicator`
