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
│   ├── home/               # Home Manager configs (shared + host-specific)
│   ├── hosts/              # Host-specific system configs
│   ├── modules/            # Reusable Nix modules (common/, darwin/, home/, nixos/)
│   └── pkgs/               # Custom package derivations (callPackage)
├── justfile                # Task runner recipes (always execute in nix/)
├── nvim/                   # Neovim configuration (LazyVim-based)
│   ├── lua/                # Lua plugins and config
│   └── stylua.toml         # Lua formatter config
├── sketchybar/             # macOS status bar config (Lua-based)
├── opencode/               # OpenCode agent configuration (stowed into ~/.config)
└── docs/                   # Agent docs (issue tracker, triage labels, domain, handoffs)
```

## Active Hosts

Only two hosts are wired in `flake.nix` outputs:

- **`Sterling-MBP`** — macOS (Darwin), aarch64
- **`kirby`** — NixOS, x86_64

> **Hostname gotcha:** the `kirby` flake output passes `hostname = "kirby-machine"` to `mkSystem` (not `"kirby"`). The `hostname` specialArg seen inside NixOS modules is `"kirby-machine"`; the flake attribute is `"kirby"`.

> **Note:** The former WSL (`hosts/nixos/wsl/`, `home/nixos/wsl/`) and Ubuntu (`home/ubuntu/`) configs have been **deleted from the working tree** — they are no longer present, not merely un-exported. Do not attempt to restore them without confirming with the user.

## Build Commands

Recipes live in the root `justfile` (`set working-directory := "nix"`), so they can be run from the repo root or any subdirectory — they always execute in `nix/`:

```bash
just darwin   # Rebuild Sterling-MBP via `nh darwin switch`
just nixos    # Rebuild kirby via `nh os switch`
just update   # Update flake inputs (`nix flake update`)
just clean    # Prune dead .app-bearing store paths, then garbage collect (`nh clean all`)
just lint     # Lint with statix
just format   # Format with nixfmt-tree (`nix fmt`)
just          # List available recipes
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
just lint
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

- **`sketchybar/`**: Lua-based status bar. Entry point is `sketchybarrc`, which loads `helpers/` and `init.lua`. Nix-managed since 2026-11 — `nix/home/darwin/sketchybar.nix` uses the `programs.sketchybar` Home Manager module (binary, Lua interpreter, SbarLua module and the launchd agent all come from Nix; the Lua tree is linked out-of-store so `helpers/init.lua`'s runtime `make` keeps working). The module's generated wrapper owns the bar's `PATH`: **every CLI the config shells out to must be listed in `extraPackages`**, and the wrapper does *not* include the rest of the Nix profile.
- **AeroSpace**: Nix-managed since 2026-11 — `nix/home/darwin/aerospace.nix` uses the `programs.aerospace` Home Manager module (config at `~/.aerospace.toml`, autostart via a launchd agent). The old stowed `aerospace/` directory is gone; it still starts `borders` on launch via `after-startup-command` — that binary is `pkgs.jankyborders` from `home/darwin/packages.nix`, not the Homebrew formula (sketchybar is started by its own launchd agent instead — launching it here as well races the lock file). `exec.env-vars.PATH` is required because AeroSpace builds its exec environment from launchd's PATH plus a hardcoded Homebrew prefix, never the Nix profile.

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
- **`typescript-language-server` pnpm-deps hash override (kirby) — REMOVED 2026-11-11.** nixpkgs rev `7fd4004d0` (2026-10-11) shipped a wrong `pnpmDeps` FOD hash for `typescript-language-server` 6.0.2, failing the build with a hash mismatch. Upstream fixed it hours later in [NixOS/nixpkgs#572951](https://github.com/NixOS/nixpkgs/pull/572951) (merge `eabfbbcf1`, 2026-10-11 20:44 UTC), so `hosts/nixos/kirby/default.nix` briefly carried a localized `nixpkgs.overlays` entry that `overrideAttrs`ed `pnpmDeps` with the corrected hash. Keeping it past the fix actively broke the 6.0.3 build (`ERR_PNPM_NO_OFFLINE_TARBALL` for vitest@5.0.5) because the hash is hardcoded per version; the overlay is gone and `hosts/nixos/kirby/default.nix` no longer carries any `nixpkgs.overlays`.
- **opencode v2 switch (2026-10-12).** `home/ai/opencode.nix` now uses `inputs.llm-agents.packages.${system}.opencode2` (OpenCode 2.x — the npm `@opencode/cli` line) instead of `.opencode` (v1). Both versions claim the `opencode` command upstream (npm ships both bin names) and cannot be installed side by side; the llm-agents package only ships `bin/opencode2`, so the module wraps it in a `symlinkJoin` that adds a `bin/opencode` alias — the standard `opencode` command keeps working and runs v2. Settings use native v2 keys: `plugins` (not `plugin`), `agents.*.disabled` (not `agent.*.disable`), and `experimental.subagent_depth = 2` (recommended by oh-my-opencode-slim so advisor subagents can read images on v2 hosts). `lsp = true` was dropped — v2 accepts the key but runs no language servers, exposes no LSP tools, and produces no diagnostics. The terminal theme moved from HM's `programs.opencode.tui` (v1 `tui.json`) to a Nix-managed `xdg.configFile."opencode/cli.json"` (`theme.name = "tokyonight"`), because v2 replaced layered `tui.json` with one global `cli.json`. Flat v1 `mcp` from `enableMcpIntegration` still works — v2 normalizes it in memory. **`xdg.configFile."opencode/cli.json"` must keep `force = true`:** v2's background `serve --service` process rewrites that path at runtime (replacing the HM symlink with a regular file, and also dropping a `service.json` sibling), so with `backupFileExtension = "backup"` set, HM backs it up on one activation and then aborts every later activation with `Existing file '…/cli.json.backup' would be clobbered` — failing `home-manager-sirwayne.service`. `force` makes HM's `checkLinkTargets` skip the collision check. Reference: [v1 → v2 migration guide](https://opencode.ai/v2/docs/migrate-v1/).
- **ashell `aws-lc` buildInputs override (kirby, 2026-11-11).** nixpkgs' cargo setup hook forces system libraries for every `buildRustPackage` build (`AWS_LC_SYS_USE_SYSTEM=1` in `cargo-setup-hook.sh`'s `cargoUseSystemLibs`), but `pkgs/by-name/as/ashell/package.nix` at rev `f4a03c0` (2026-11-07) did not put `aws-lc` in `buildInputs`, so `aws-lc-sys` 0.44.0 aborted with "AWS_LC_SYS_USE_SYSTEM=1 requires a system-installed AWS-LC, but none was found." Upstream fixed it in [NixOS/nixpkgs commit `1fb6001460b6`](https://github.com/NixOS/nixpkgs/commit/1fb6001460b6) ("ashell: fix build with forced system libraries", 2026-11-09) — after the pinned rev. `home/nixos/kirby/ashell.nix` now overrides the HM `programs.ashell.package` with `buildInputs ++ [ pkgs.aws-lc ]`. **Remove the override once `nixpkgs` is updated past `1fb6001460b6`.**
- **sketchybar moved from Homebrew to Home Manager (Sterling-MBP, 2026-11).** `home/darwin/sketchybar.nix` now owns the binary, the Lua interpreter, the SbarLua module and the launchd agent via `programs.sketchybar` (`configType = "lua"`, `sbarLuaPackage = pkgs.sbarlua`). Three traps are load-bearing:
  - **The wrapper owns `PATH`.** It is built from `extraPackages` plus `/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/homebrew/bin` — the rest of the Nix profile (`/etc/profiles/per-user/$USER/bin`) is *not* included. Any new CLI the Lua config shells out to must be added to `extraPackages`, or it fails with exit 127 in `~/Library/Logs/sketchybar/sketchybar.err.log`.
  - **`sketchybarrc` must establish `package.path` itself.** Lua's `require` only found `helpers`/`init` through the built-in cwd-relative `./?.lua`, which worked because sketchybar chdirs into `$CONFIG_DIR`. The generated wrapper exports `LUA_PATH` and `makeWrapper`'s `--prefix` *replaces* the default path (no `;;` expansion), so `./?.lua` vanishes and the bar comes up empty with `module 'helpers' not found`. The module only adds `~/.config/sketchybar/?.lua;…` to `LUA_PATH` when `programs.sketchybar.config` is set, which this config cannot use. `sketchybarrc` therefore derives the directory from `arg[0]` (falling back to `$CONFIG_DIR`, then `.`) and prepends it to `package.path`.
  - **`programs.sketchybar.config` must not be used.** Its `source` option routes through `lib.pathIsDirectory` at eval time, which cannot see through `mkOutOfStoreSymlink`'s store path; it then targets `<config>/sketchybarrc` instead of the directory and produces an empty config dir. The link is created with `xdg.configFile."sketchybar"` instead.
  - **The config dir cannot live in the store.** `helpers/init.lua` runs `make` into `helpers/**/bin`, and `items/apple.lua` / `items/widgets/{cpu,wifi}.lua` exec `$CONFIG_DIR/helpers/**/bin/*`. A read-only copy breaks CPU/network graphs and the Apple menu *silently*.
  - AeroSpace's `exec.env-vars.PATH` (`home/darwin/aerospace.nix`) is required for the same reason: upstream builds its exec env from launchd's PATH plus a hardcoded Homebrew prefix, so `sketchybar --trigger` and `$(aerospace list-monitors …)` were both `command not found` there.
  - `brew services stop sketchybar` is mandatory before switching — it unloads the agent and deletes its plist. Do not hardcode the plist name: brew 5.x labels it `sh.brew.sketchybar` (older releases `homebrew.mxcl.sketchybar`), so verify with `launchctl list | grep -i sketchybar` and `ls ~/Library/LaunchAgents/*sketchybar*` rather than a fixed path. Two `KeepAlive` agents race `/tmp/sketchybar_$USER.lock` and one crash-loops every 10 s.
  - Resolved ambiguity worth remembering: `pkgs.sbarlua` statically vendors Lua 5.5.0 and performs `luaL_checkversion_` against the host interpreter, so interpreter and module must come from one `pkgs` (`sbarlua.passthru.luaModule` → `lua5_5` 5.5.1). Verified loading the Nix `.so` from Nix `lua` before the switch. Upstream SbarLua is unmaintained (last commit 2026-03-06) and has open Mach-IPC/zombie-process bugs (#62–#69); Nix removes the version gamble, not the maintenance risk.
- **Lix on Darwin** — `nix.package = pkgs.lixPackageSets.stable.lix` replaces the Nix daemon binary; `nix.enable` is not set in Darwin modules (the nix-darwin module does not manage the daemon). Determinate Nix is no longer used.
- **`mac-app-util`'s transitive `nixpkgs.lib` follows `nixpkgs-darwin` (2026-11-16).** Lix prints `warning: using or as an identifier is deprecated` pointing at `lib/trivial.nix`, `lib/options.nix` and `lib/default.nix` on every **Darwin** evaluation. Those files are *not* this flake's nixpkgs — both `nixpkgs` and `nixpkgs-darwin` already quote `"or"` (and `lib."or"`) upstream. They come from `mac-app-util` → `cl-nix-lite` → `flake-parts` → `nix-community/nixpkgs.lib`, pinned at rev `2075416` (2025-12-14). Neither mac-app-util (`039f33d`) nor cl-nix-lite (`eb58472`) has moved past that flake-parts/lib pair upstream, so `flake.nix` sets `inputs.cl-nix-lite.inputs.flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs-darwin"`. flake-parts only reads `nixpkgs-lib.lib`, which nixpkgs also exports, so the swap is safe; drop the edge if cl-nix-lite's pin ever ships a newer lib. The warning text's own suggestion, `nix.settings.extra-deprecated-features = [ "or-as-identifier" ]`, works on Lix but silences the whole class instead of fixing the source. Unrelated `stdenv.isDarwin is deprecated` warnings were repo-local: `home/neovim.nix` used `pkgs.stdenv.isDarwin`, now `pkgs.stdenv.hostPlatform.isDarwin`.
- **lanzaboote bumped to `v1.2.0` (2026-11-16).** `v1.1.0` pulled rust-overlay `8534567`, whose `lib/mk-aggregated.nix` still read `stdenv.isLinux`/`stdenv.isDarwin` — the source of the last two `stdenv.is… is deprecated` warnings on kirby's **system** eval (`--option abort-on-warn true` traces it to `lzbt → rust-default`). `v1.2.0` pins rust-overlay `1fb104a`, which uses `stdenv.hostPlatform.is*`. The 1.2.0 changelog changes are Measured Boot only (PCR4 locking, max generations 8→4), and kirby sets `boot.lanzaboote.enable` without `measuredBoot`, so the bump is a no-op there. The same sweep migrated `home/nixos/kirby/rofi.nix` off the deprecated `programs.rofi.{modes,terminal,extraConfig}` aliases onto `programs.rofi.settings` (native Rasi keys, Nerd Font glyphs preserved byte-for-byte).
- **HEX dictation installed declaratively (kirby, 2026-11-16).** `home/nixos/kirby/hex.nix` enables `programs.hex` from the `hex` flake input (`github:anomalyco/hex`) via upstream's `homeManagerModules.hex` — no `nix profile add`, so the binary, the `systemd --user` service and the model downloader are all in the generation. Three load-bearing details: (1) the input sets `inputs.nixpkgs.follows = "nixpkgs"` because upstream's `docs/nix.md` warns that a Hex built against its own older nixpkgs pin can link an older glibc than kirby's graphics drivers, find no Vulkan adapter and never open a window; (2) `systemdTarget` stays the default `graphical-session.target` for the same reason as ashell — `hyprland-session.target` is never started while `wayland.windowManager.hyprland.systemd.enable = false`; (3) the package is **Linux-only** (`x86_64-linux`/`aarch64-linux`), so unlike `zen-browser`/`llm-agents` it is imported from `home/nixos/kirby/`, never shared home; on Sterling-MBP the upstream **Homebrew cask** is used instead — `hosts/darwin/Sterling-MBP/homebrew.nix` taps `anomalyco/tap` and lists the tap-qualified cask `anomalyco/tap/hex`. Homebrew 6.x sets `HOMEBREW_REQUIRE_TAP_TRUST`, which makes a bare `brew install --cask anomalyco/tap/hex` fail with *"Refusing to load cask … from untrusted tap"*; nix-darwin's `homebrew.casks` entries default to `trusted = true`, so the Brewfile line is `cask "anomalyco/tap/hex", trusted: true` and no `nix-homebrew.trust`/`extraEnv` entry is needed (verified 2026-11-16: `brew bundle` installed the cask and recorded it in `~/.homebrew/trust.json`). Models land in `~/.local/share/hex` (`installModel = true` downloads the selected one at login) and are not in the store; in-app updates never replace the Nix install — bump the input instead.
- **`nixpkgs-darwin` pinned to `5b0748384e` (2026-11-21) — swift-collections build failure.** Channel rev `b758f162` (2026-11-20 06:23) fails to build `swift-collections-1.7.6` on aarch64-darwin:
  ```
  install_name_tool: changing install names or rpaths can't be redone for: …/libInternalCollectionsUtilities.dylib
  (for architecture arm64) because larger updated load commands do not fit
  ```
  because the Swift CMake build links its dylibs without header padding. Upstream fixed it hours later in [NixOS/nixpkgs@`5b0748384e`](https://github.com/NixOS/nixpkgs/commit/5b0748384e) ("swiftPackages.swift-collections: ensure there is enough room for install names on Darwin", 2026-11-20 18:51 UTC) by adding `NIX_LDFLAGS = "-headerpad_max_install_names"`. **`nixpkgs-unstable` had not advanced past that commit at the time of pinning** (head was `9996594`, 15:12 UTC), so a plain `nix flake update` would still fail. The failure takes down the whole Darwin build because the chain is `swift-collections → swiftpm → swift → dockutil → mac-app-util`; only `dockutil`/`mac-app-util` are left to compile once the input is bumped (the Swift chain substitutes from cache).
  A host-level `nixpkgs.overlays` override of `swiftPackages.swift-collections` **does not work here**: mac-app-util's modules resolve their binary from `self.packages.${system}.default`, i.e. its own evaluation of the input (`inputs.nixpkgs.follows = "nixpkgs-darwin"`), not our overlaid `pkgs`. Pinning `nixpkgs-darwin.url` in `flake.nix` is the only lever. **Revert that URL to `github:NixOS/nixpkgs/nixpkgs-unstable` once the branch contains `5b0748384e`** — grep for `NIX_LDFLAGS` in `pkgs/development/compilers/swift/by-name/sw/swift-collections/package.nix` on `nixpkgs-unstable` to check.

### Helper Functions in `flake.nix`

- `mkSpecialArgs` — builds `specialArgs` with `username`, `hostname`, `inputs`, `pkgs-stable`
- `mkStablePkgs` — resolves the correct stable nixpkgs legacyPackages by `system` (via `getStableNixpkgs`)
- `mkHomeManagerConfig` — creates a Home Manager user config with `extraSpecialArgs`
- `mkSystem` — creates a `nixosSystem`
- `mkDarwin` — creates a `darwinSystem`

### Auto-Upgrade

`system.autoUpgrade` is **enabled** in `hosts/nixos/kirby/default.nix`: `dates = "Mon,Thu 04:00"`, `allowReboot = false`, flake `/home/sirwayne/dotfiles/nix#kirby`, updating the `nixpkgs` and `nixpkgs-darwin` inputs (`--update-input`) before the rebuild. It does not touch the Darwin host.

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

`.stowrc` targets `~/.config` and ignores `nix/`, `archive/`, `.stowrc`, plus the two Home Manager-owned files inside `opencode/` (`opencode/opencode.json`, `opencode/cli.json`). `nvim/` and `opencode/` are stowed into `~/.config`; `sketchybar/` is linked there by Home Manager instead (`xdg.configFile."sketchybar"`, an out-of-store symlink back into the repo).

## AI / MCP Configuration

- `opencode/opencode.json` — OpenCode agent settings and MCP server registry (Astro, Grafana, Kubernetes, NixOS, OpenTofu). It is written by Home Manager through the stowed `opencode/` directory, so the repo copy is a store symlink and gitignored.
- `nix/home/ai/` — Home Manager modules for the AI tooling: `claude-code.nix`, `codex.nix` (Codex CLI + ChatGPT), `opencode.nix` (OpenCode 2 + desktop app), `antigravity.nix`, and `mcp.nix` (MCP server wiring).

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

1. **Test before committing**: Always run `just lint` and `just format` (from the repo root or anywhere under it).
2. **Modularize**: Create separate files for distinct concerns.
3. **Document host-specifics**: Add comments for non-obvious configurations.
4. **Use flakes**: All active configurations use the flake-based setup.
5. **Follow the structure**: Place files in appropriate directories per the project structure.
6. **Do not resurrect deleted configs**: the WSL/Ubuntu configs have been removed from the tree; do not add them back without confirming with the user.

## Known Issues

### macOS Tahoe (26.x): `com.apple.macl` blocks `nix-collect-garbage`

**Root cause:** When Ghostty (or any GUI app launched from `/nix/store/...`) runs, macOS stamps the `com.apple.macl` extended attribute on every file inside the `.app` bundle. On macOS 26.x (Tahoe), this xattr is **TCC-protected** — not even root can strip it with `xattr -d` (confirmed: all nested files return `EPERM`). `nix-collect-garbage` calls `chmod -R +w` on stale store paths before deleting them; the chmod hits EPERM on every macl'd file, and the entire GC aborts with "0 store paths deleted".

**The old workaround (`sudo xattr -dr com.apple.macl ...`) is permanently broken on Tahoe.** Do not re-add it. The justfile `clean:` recipe now handles this via a pre-clean step that takes the dead-path list from `nix-store --gc --print-dead`, finds every `.app` bundle in the store, and `sudo rm -rf`s the **whole dead store path** for each one that is on that list. Root can unlink entries from `/nix/store` without chmod'ing the files (unlink only needs write-perm on the parent dir, not the file), which sidesteps the SACL entirely.

**Liveness comes from nix, not from referrer counts.** The previous `nix-store --query --referrers` heuristic was wrong in both directions: a path can have referrers yet still be garbage (its referrer is itself garbage), and referrer data proved unstable between runs. It also removed only the `.app` subdirectory, leaving a **half-deleted store path** behind (seen 2026-11-14: `ghostty-bin-1.3.1` persisted with an empty `Applications/`). Whole-path removal on a `--print-dead` verdict fixes both. If any `rm -rf` fails, the recipe now aborts with a clear error **before** running GC, instead of letting `nix-collect-garbage` fail on the chmod.

**Recurrence:** Every `just darwin` cycle produces a new `ghostty-bin` hash. Once it becomes stale and has been launched, it retains macl and blocks GC. The pre-clean step handles this automatically on every `just clean`.

**If GC still reports `chmod '…': Operation not permitted`:** run `just clean` again — the abort-before-GC guard means a failed prune now stops early and prints the offending path. A store path that is already half-deleted (empty `Applications/`, left by the pre-2026-11-14 heuristic) is dead but carries no `.app`, so the prune skips it and plain GC removes it normally.

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
