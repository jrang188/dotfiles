# External Integrations

**Analysis Date:** 2026-05-26

## APIs & External Services

**Package Registries / Substituters (`nix/modules/common/nix-core.nix`):**
- **cache.nixos.org** — default Nix binary cache
- **nix-community.cachix.org** — community-built derivations
- **cachix.cachix.org** — Cachix self-hosted cache
- **hyprland.cachix.org** — Hyprland prebuilt binaries
- **ghostty.cachix.org** — Ghostty terminal prebuilt binaries
- **devenv.cachix.org** — devenv cache
- **cache.numtide.com** — numtide cache (used for `llm-agents.nix`)

**Flake Source Repositories (`nix/flake.nix`):**
- `github:NixOS/nixpkgs` (multiple refs)
- `github:LnL7/nix-darwin`
- `github:nix-community/home-manager`
- `github:hraban/mac-app-util`
- `github:nix-community/lanzaboote/v1.0.0`
- `github:0xc000022070/zen-browser-flake`
- `github:numtide/llm-agents.nix`
- `https://flakehub.com/f/DeterminateSystems/determinate/*`

**AI / LLM Services:**
- **OpenCode (`opencode/opencode.json`):** primary AI agent, model `opencode-go/mimo-v2-pro`, with provider presets for `openai` and `opencode-go` in `opencode/oh-my-opencode-slim.json` (uses `gpt-5.5`, `gpt-5.4-mini`, `glm-5.1`, `deepseek-v4-pro`, `minimax-m2.7`, `kimi-k2.6`, etc.)
- **Claude Code (`nix/home/ai/claude-code.nix`):** enabled via `programs.claude-code` from `llm-agents` flake input; MCP integration enabled
- **CodeCompanion (Neovim, `nvim/lua/plugins/codecompanion.lua`):** uses `https://opencode.ai/zen/go/v1/messages` endpoint via `anthropic` adapter, model `minimax-m2.7`
  - Auth: `cmd:op read 'op://Development/opencode_go/credential' --no-newline` (1Password CLI lookup)

**MCP Servers (`nix/home/ai/mcp.nix` and `opencode/opencode.json`):**
- `nixos` — local, command `uvx mcp-nixos`
- `astro` — remote, `https://mcp.docs.astro.build/mcp`
- `kubernetes` — local, `npx -y kubernetes-mcp-server@latest`
- `pulumi` — remote, `https://mcp.ai.pulumi.com/mcp`

**External SaaS/Tools available via CLI (`nix/home/packages.nix`):**
- **GitHub** — `gh` CLI
- **Stripe** — `stripe-cli`
- **1Password** — `_1password-cli` (Darwin/all) and `_1password` + `_1password-gui` on NixOS (`nix/modules/nixos/1password.nix`)
- **AWS** — `awscli2`
- **Google Cloud** — `google-cloud-sdk`
- **Oracle Cloud** — `oci-cli`
- **Pulumi** — `pulumi-bin`, `pulumi-esc` (HCP Vault alternative)
- **CodeCrafters** — `codecrafters-cli`
- **Cachix** — `cachix` (for publishing to/auth with caches)

## Data Storage

**Databases:**
- Not applicable — this is a dotfiles/system configuration repository, no application databases. SQL language server `sqls` is installed (`nix/home/neovim.nix`) for editor support.

**File Storage:**
- Local filesystem only
- Google Drive client installed via Homebrew (`nix/hosts/darwin/Sterling-MBP/homebrew.nix`)
- Nix store at `/nix/store` (kirby auto-optimised; Darwin optimised weekly at Monday 02:00 — `nix/modules/darwin/default.nix`)

**Caching:**
- Nix substituters listed above act as build cache
- `programs.nh` configured in `nix/home/default.nix` for cleanup: `--keep-since 4d --keep 3 --optimise`, weekly
- NixOS `nix.gc` runs daily, `--delete-older-than 7d` (`nix/modules/nixos/default.nix`)

## Authentication & Identity

**Auth Provider:**
- **1Password** — primary credential store
  - macOS: `_1password-cli` from Nix packages
  - NixOS: `_1password-gui` with PolKit integration for `${username}` (`nix/modules/nixos/1password.nix`)
  - Browser allowlist for Zen via `/etc/1password/custom_allowed_browsers` (NixOS)
  - KDE autostart entry for 1Password silent launch (`nix/home/nixos/kirby/kde.nix`) — disabled when Hyprland is enabled
  - Hyprland autostart: `1password --silent` (`nix/home/nixos/kirby/hyprland.nix` line 23)
  - Used by CodeCompanion via `op read` (`nvim/lua/plugins/codecompanion.lua`)

**System Authentication:**
- **TouchID for sudo** on Darwin (`nix/modules/darwin/security.nix` — `security.pam.services.sudo_local.touchIdAuth = true`)
- **Howdy** facial recognition on kirby (`nix/hosts/nixos/kirby/howdy.nix`) — uses IR emitter, `dark_threshold = 85`
- **Secure Boot** on kirby via `lanzaboote` (`nix/hosts/nixos/kirby/secure-boot.nix`) with `sbctl` for key management at `/var/lib/sbctl`

**Git Identity (`nix/home/git.nix`):**
- `user.name = "Justin Ang"`
- `user.email = "justinang177@gmail.com"`
- `init.defaultBranch = "main"`, `push.autoSetupRemote = true`, `pull.ff = "only"`
- LFS enabled, signing disabled (`signing.format = null`)
- On WSL hosts: `core.sshCommand = "ssh.exe"` to use Windows-side SSH

## Monitoring & Observability

**Error Tracking:**
- None — system configuration repository

**Logs:**
- Standard systemd journals on NixOS
- macOS unified logging on Darwin
- Sketchybar logs via Lua `print` and `sketchybar --trigger` events

## CI/CD & Deployment

**Hosting:**
- N/A — local system configurations applied via `darwin-rebuild` / `nixos-rebuild` / `nh`

**CI Pipeline:**
- No remote CI defined in the repository
- Local CI replacement: `pre-commit` hooks via `nix/.pre-commit-config.yaml` (runs `treefmt`, `statix check`, whitespace/EOF/YAML/JSON validation)
- `act` is installed in `nix/home/packages.nix` for local GitHub Actions execution

**Auto-Upgrade:**
- `kirby` has a commented-out `system.autoUpgrade` block in `nix/hosts/nixos/kirby/default.nix` (lines 64-75) — currently disabled, would rebuild from `/home/sirwayne/dotfiles/nix#kirby` on Mon/Thu at 04:00

## Environment Configuration

**Required env vars (set via Nix, not external):**
- `PATH` extended with `$HOME/.local/bin`, `/usr/local/go/bin`, `$GOPATH/bin` in `nix/home/zsh.nix`
- `GOPATH = $HOME/go`
- `NIXOS_OZONE_WL = "1"` on kirby (`nix/home/nixos/kirby/hyprland.nix`)
- `GTK_THEME`, `QT_QPA_PLATFORMTHEME`, `QT_STYLE_OVERRIDE`, `ELECTRON_OZONE_PLATFORM_HINT` for theming (`nix/home/nixos/kirby/theme.nix`)

**Secrets location:**
- **1Password** is the source of truth (referenced by CodeCompanion via `op read 'op://Development/opencode_go/credential'`)
- No `.env` files committed; none referenced in any module
- Lanzaboote PKI bundle: `/var/lib/sbctl` (kirby)

## Webhooks & Callbacks

**Incoming:**
- None

**Outgoing:**
- Hyprland session lifecycle hooks (`exec-once`, idle listeners, sleep hooks in `nix/home/nixos/kirby/hyprland.nix`)
- Sketchybar event triggers from shell:
  - `brew_update` triggered after `brew upgrade/update/outdated` (`nix/home/zsh.nix`)
  - `aerospace_workspace_change`, `aerospace_focus_change` from aerospace (`aerospace/aerospace.toml`)
- WSL hosts establish UNIX socket bridge to Windows Discord IPC via `socat` + `npiperelay.exe` (`nix/home/ubuntu/default.nix`, `nix/home/nixos/wsl/default.nix`)

## DNS / Networking

**NixOS kirby (`nix/hosts/nixos/kirby/networking.nix`):**
- `NetworkManager` enabled with `networkmanager-openvpn` plugin
- DNS resolved by `dnscrypt-proxy2` listening on `127.0.0.1`/`::1`
- Encrypted DNS-over-HTTPS via AdGuard IPv6 (`adguard-dns-doh-ipv6`)
- Public resolvers list pulled from `raw.githubusercontent.com/DNSCrypt/dnscrypt-resolvers/master/v3/public-resolvers.md` and `download.dnscrypt.info/resolvers-list/v3/public-resolvers.md`

**SSH (`nix/hosts/nixos/kirby/desktop.nix`):**
- `services.openssh.enable = true` on kirby

**File transfer:**
- **LocalSend** enabled with open firewall on NixOS (`nix/modules/nixos/localsend.nix`); cask installed on Darwin via Homebrew
- **KDE Connect** enabled on kirby (`programs.kdeconnect.enable = true` in `nix/hosts/nixos/kirby/default.nix`) and via Homebrew tap `imshuhao/kdeconnect` on Darwin

## Homebrew Integrations (Darwin only — `nix/hosts/darwin/Sterling-MBP/homebrew.nix`)

**Taps:** `nikitabobko/tap`, `FelixKratz/formulae`, `homebrew/services`, `grishka/grishka`, `imshuhao/kdeconnect`

**Brews:** `sketchybar`, `borders`, `lua`, `kafka`, `mole`, `media-control`, `scrcpy`

**Casks:** `raycast`, `scroll-reverser`, `warp`, `aerospace`, `karabiner-elements`, `sf-symbols`, `font-sf-mono`, `font-sf-pro`, `orbstack`, `localsend`, `kdeconnect`, `intellij-idea`, `zed`, `google-drive`, `adobe-acrobat-reader`, `android-platform-tools`

**Activation:** `homebrew.onActivation.cleanup = "zap"` — uninstalls anything not declared in this file.

---

*Integration audit: 2026-05-26*
