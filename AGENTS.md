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

> **Note:** The former WSL (`hosts/nixos/wsl/`, `home/nixos/wsl/`) and Ubuntu (`home/ubuntu/`) configs have been **deleted from the working tree** — they are no longer present, not merely un-exported. Do not attempt to restore them without confirming with the user.

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
- **hy3 removed (2026-08-29).** `kirby` previously used the hy3 plugin (pinned to upstream `hl0.56.0.1`, ABI-matched to Hyprland 0.56.0 specifically — hy3's `hl<hyprland-version>` tag scheme ties each release to one exact Hyprland patch version, so every nixpkgs Hyprland point-release broke it again). After repeated breakage across nixpkgs bumps, hy3 was dropped in favor of Hyprland's built-in `dwindle` layout. `home/nixos/kirby/hyprland.nix` now sets `general.layout = "dwindle"` with a `dwindle.preserve_split` block, and the old `hy3:movewindow` / `hy3:changegroup` binds were remapped to core dispatchers (`movewindow`, `togglegroup` — confirmed against Hyprland's archived 0.54.0 dispatcher docs, since these predate the plugin and need no plugin to work).
- **`nixpkgs` unpinned again (2026-08-29), tracks `nixos-unstable`.** Briefly pinned to `e2587caef70cea85dd97d7daab492899902dbf5d` (2026-07-23) after nixpkgs-unstable shipped a Qt6 regression sometime before 2026-08-23 — every Qt6 app in a Wayland session failed with "no Qt platform plugin could be initialized," which crashed `hyprpolkitagent` (looping uwsm Hyprland logins back to SDDM) and broke `hyprlandPlugins`/hy3 ABI compat via an unrelated Hyprland version bump in the same window. Root cause was never bisected to an exact nixpkgs commit. The pin was dropped and `programs.zen-browser` re-enabled once hy3 itself was removed (see above) — hy3 was the only thing forcing an exact Hyprland version, and zen-browser's build needs a post-2026-08-03 nixpkgs (`ffmpeg_8` support, `nixpkgs#e7e521c4f`) that the pin was blocking. **The Qt6 regression's fix status upstream is unverified** — if uwsm Hyprland logins start looping back to SDDM again after a `nix flake update`, check `journalctl -b -1 | grep -i "no Qt platform plugin"` for `hyprpolkitagent` first; re-pinning `nixpkgs` to a known-good rev (check `nixos-version --json` on whatever generation last worked) is the fastest fix.
- **hyprlang → Lua config migration (DONE 2026-08-30).** `home/nixos/kirby/hyprland.nix` now sets `configType = "lua"`; the whole `settings` attrset was rewritten to the lua-config schema (top-level keys map to `hl.<key>(...)` calls — `config` for `hl.config()` look-and-feel, `monitor`/`curve`/`animation`/`bind` as lists, `on` for the `hl.on("hyprland.start", ...)` autostart hook). Dispatcher calls and anything that must render as Lua code (not a string literal) go through `lib.generators.mkLuaInline`, which required adding `lib` to the module's function args. Verified by building `nixosConfigurations.kirby.config.home-manager.users.sirwayne.home.activationPackage` and inspecting the rendered `hyprland.lua` output store path directly. `home.stateVersion` was deliberately **not** bumped — it's shared across all hosts in `home/default.nix` (not host-specific as previously assumed here), and is unnecessary since `configType` is set explicitly rather than relying on the stateVersion-derived default. Dispatcher reference: [hyprland-wiki `dispatchers.md`](https://github.com/hyprwm/hyprland-wiki/blob/main/content/configuring/core/dispatchers.md); example config: [Hyprland's `example/hyprland.lua`](https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua).
- **`typescript-language-server` pnpm-deps hash override (kirby, 2026-10-12).** nixpkgs rev `7fd4004d0` (2026-10-11) shipped a wrong `pnpmDeps` FOD hash for `typescript-language-server` 6.0.2, failing the build with a hash mismatch. Upstream fixed it hours later in [NixOS/nixpkgs#572951](https://github.com/NixOS/nixpkgs/pull/572951) (merge `eabfbbcf1`, 2026-10-11 20:44 UTC) — the pinned rev is 209 commits behind it. `hosts/nixos/kirby/default.nix` carries a localized `nixpkgs.overlays` entry that `overrideAttrs`s `pnpmDeps` with the corrected hash (`sha256-xR/EF60lVBsITKgH7wCM2wHM46PFQevD51KfCENSUH4=`). **Remove the overlay once `nixpkgs` is updated past `eabfbbcf`** — the hash is hardcoded per version and would break the next `typescript-language-server` bump.
- **opencode v2 switch (2026-10-12).** `home/ai/opencode.nix` now uses `inputs.llm-agents.packages.${system}.opencode2` (OpenCode 2.x — the npm `@opencode/cli` line) instead of `.opencode` (v1). Both versions claim the `opencode` command upstream (npm ships both bin names) and cannot be installed side by side; the llm-agents package only ships `bin/opencode2`, so the module wraps it in a `symlinkJoin` that adds a `bin/opencode` alias — the standard `opencode` command keeps working and runs v2. Settings use native v2 keys: `plugins` (not `plugin`), `agents.*.disabled` (not `agent.*.disable`), and `experimental.subagent_depth = 2` (recommended by oh-my-opencode-slim so advisor subagents can read images on v2 hosts). `lsp = true` was dropped — v2 accepts the key but runs no language servers, exposes no LSP tools, and produces no diagnostics. The terminal theme moved from HM's `programs.opencode.tui` (v1 `tui.json`) to a Nix-managed `xdg.configFile."opencode/cli.json"` (`theme.name = "tokyonight"`), because v2 replaced layered `tui.json` with one global `cli.json`. Flat v1 `mcp` from `enableMcpIntegration` still works — v2 normalizes it in memory. Reference: [v1 → v2 migration guide](https://opencode.ai/v2/docs/migrate-v1/).
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
6. **Do not resurrect deleted configs**: the WSL/Ubuntu configs have been removed from the tree; do not add them back without confirming with the user.

## Known Issues

### macOS Tahoe (26.x): `com.apple.macl` blocks `nix-collect-garbage`

**Root cause:** When Ghostty (or any GUI app launched from `/nix/store/...`) runs, macOS stamps the `com.apple.macl` extended attribute on every file inside the `.app` bundle. On macOS 26.x (Tahoe), this xattr is **TCC-protected** — not even root can strip it with `xattr -d` (confirmed: all nested files return `EPERM`). `nix-collect-garbage` calls `chmod -R +w` on stale store paths before deleting them; the chmod hits EPERM on every macl'd file, and the entire GC aborts with "0 store paths deleted".

**The old workaround (`sudo xattr -dr com.apple.macl ...`) is permanently broken on Tahoe.** Do not re-add it. The Makefile `clean:` target now handles this via a pre-clean step that discovers all `.app` bundles in the nix store, queries `nix-store --query --referrers` for each, and `sudo rm -rf`s any with zero non-self referrers. Root can unlink entries from `/nix/store` without chmod'ing the files (unlink only needs write-perm on the parent dir, not the file), which sidesteps the SACL entirely.

**Recurrence:** Every `make darwin` cycle produces a new `ghostty-bin` hash. Once it becomes stale and has been launched, it retains macl and blocks GC. The pre-clean step handles this automatically on every `make clean`.

**Do NOT:**
- Replace the `clean:` target with `xattr -dr com.apple.macl` — permanently broken on Tahoe.
- Use `2>/dev/null || true` to mask GC failures — the root cause is deterministic, not transient.
- Attempt to strip `com.apple.macl` with any `xattr` variant — blocked by TCC on macOS 26.x.

### kirby: uwsm Hyprland login loop — `systemd.enable` must stay `false` (RESOLVED 2026-08-29)

**Symptom:** selecting "Hyprland (uwsm-managed)" at SDDM appeared to log in, then immediately returned to the greeter. The plain `hyprland.desktop` session worked fine. No error surfaced anywhere: no crash, no coredump, exit code 0.

**Why it was hard to spot:** in the journal the compositor unit looks *successful* —
```
wayland-wm@hyprland.desktop.service: Consumed ~800ms CPU time over ~1.0s wall clock time
wayland-wm@hyprland.desktop.service: Triggering OnSuccess= dependencies.
```
Hyprland's own detailed log goes to `/run/user/1000/hypr/<instance>/hyprland.log`, which is **deleted when the instance exits**, so the actual reason is gone by the time you look. The `~1.0s` runtime plus `OnSuccess=` is the fingerprint.

**Root cause:** home-manager's `wayland.windowManager.hyprland.systemd.enable` defaults to **true**, which injects into `hyprland.conf`:
```
exec-once = ... && systemctl --user stop hyprland-session.target && systemctl --user start hyprland-session.target
```
`hyprland-session.target` has `PropagatesStopTo=graphical-session.target`. Under uwsm the compositor is chained to that target (`wayland-session@hyprland.desktop.target` `BindsTo=graphical-session.target`; `wayland-wm@hyprland.desktop.service` `BindsTo=wayland-session@...`), so the momentary `stop` propagates *back into the compositor's own unit* and SIGTERMs Hyprland about a second after a fully successful start. Upstream report: [hyprwm/Hyprland#15688](https://github.com/hyprwm/Hyprland/issues/15688).

**Fix:** `systemd.enable = false` in `home/nixos/kirby/hyprland.nix`. uwsm brings up `graphical-session.target` itself, so nothing is lost under uwsm. **Do not remove this** — it is not redundant, and the default is `true`.

**Trade-off:** the plain (non-uwsm) `hyprland.desktop` session no longer starts `graphical-session.target`, so `hypridle` / `hyprpaper` / `hyprsunset` / `swaync` (all `WantedBy=graphical-session.target`) will not autostart there. Log in via "Hyprland (uwsm-managed)".

**It is a race, and it was latent for months — not introduced by any update.** The hook fires from the compositor's own `exec-once` chain: `dbus-update-activation-environment` exports `WAYLAND_DISPLAY` (which releases uwsm's `wayland-session-waitenv.service` and lets uwsm begin activating `graphical-session.target`), and the very next command in the same `&&` chain is the `systemctl --user stop`. If the stop job lands before `graphical-session.target` activates, it's a no-op and the session lives; if activation wins, the stop cascades and kills the compositor. Journal proof from 2026-08-29: **the same generation 143 closure survived 1h38m at 20:52 and died in 1.0s at 22:35 the same evening** (and had survived 22min and 6h sessions on Jul 26–27). The win/loss is visible in the user-session target order: winners log `Reached target Current graphical user session` → `Reached target Hyprland compositor session` with no stops; losers log `Reached target Startup of XDG autostart applications` immediately followed by `Stopped target ...` cascading down. gen143's generated config (still in the nix store, `home-manager-files/.config/hypr/hyprland.conf` line 1) contains the identical hook, confirming no config change caused the flip. Why the race bias flipped on Aug 29 was never identified (ruled out: uwsm 0.26.6→0.26.7 is cosmetic, systemd/HM identical across win+loss on the same closure, NTP clock-jump timing doesn't correlate).

**This was documented online all along:** the [NixOS Wiki Hyprland page](https://wiki.nixos.org/wiki/Hyprland) carries an explicit warning — "If you use the Home Manager module, make sure to disable systemd integration, as it conflicts with UWSM" with the exact `systemd.enable = false` fix — plus [hyprwm/Hyprland#15688](https://github.com/hyprwm/Hyprland/issues/15688) (Aug 2026, with a comment diagnosing the identical home-manager mechanism). Home-manager's own docs do NOT mention uwsm (repo searched, zero hits), so the wiki is the discoverable source.

This reproduced identically on Hyprland 0.56.0 and 0.56.2, with and without hy3, and on both the old and new nixpkgs — because it is a home-manager config issue. The Qt6 "no Qt platform plugin could be initialized" errors seen in the same journals were a real *concurrent* nixpkgs regression (it broke `hyprpolkitagent` and Plasma), but it was never what caused the uwsm loop; that regression is gone as of nixpkgs `83199d0` (0 occurrences).

### kirby: KDE Plasma session fails to start (kwin/DRM, unrelated to Hyprland)

**Symptom:** Selecting `plasma.desktop` at SDDM starts the session but every Plasma component (`plasmashell`, `ksmserver`, `kded6`, `ksplashqml`, etc.) immediately fails with "no Qt platform plugin could be initialized." Hyprland (uwsm or not) is unaffected — `hyprpolkitagent`, also Qt6, starts fine in the same boot.

**Root cause (partial):** `journalctl` shows Plasma's own `kwin_wayland` compositor failing before any Plasma app can connect:
```
kwin_vulkan: Device AMD Radeon RX 480 Graphics (RADV POLARIS10) misses required Vulkan extensions
kwin_vulkan: VK_EXT_image_drm_format_modifier
...
kwin_wayland_drm: atomic commit failed: Permission denied
```
"No Qt platform plugin" is a downstream symptom — there's no live Wayland socket for Plasma's apps to connect to because kwin itself didn't come up. The "Permission denied" on the atomic commit looks like a DRM-master handoff conflict: SDDM's greeter also runs its own `kwin_wayland` for the login screen, and the Plasma session's `kwin_wayland` may be failing to acquire the GPU because the greeter's compositor didn't release it cleanly. Not yet root-caused past this point (not bisected, no fix attempted).

**Confirmed pre-existing and unrelated to hy3/nixpkgs pinning:** reproduced identically on 2026-07-26 (before any of the hy3/uwsm/Qt6-regression work documented above) and on nixpkgs rev `e2587ca` (2026-07-23, briefly pinned then dropped — see "Known Pinning / Overrides"). Removing hy3 or (un)pinning `nixpkgs` does not touch this.

## Agent skills

### Issue tracker

GitHub Issues. See `docs/agents/issue-tracker.md`.

### Triage labels

Default labels: `needs-triage`, `needs-info`, `ready-for-agent`, `ready-for-human`, `wontfix`. See `docs/agents/triage-labels.md`.

### Domain docs

Single-context — `CONTEXT.md` + `docs/adr/` at repo root. See `docs/agents/domain.md`.
