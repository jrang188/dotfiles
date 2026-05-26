# Codebase Structure

**Analysis Date:** 2026-05-26

## Directory Layout

```
dotfiles/
├── CLAUDE.md                       # Agent guidelines (repo conventions)
├── AGENTS.md                       # Generic agent instructions
├── README.md                       # (near-empty placeholder)
├── .stowrc                         # GNU stow defaults (target ~/.config)
├── .editorconfig                   # 2-space indent for Nix
├── .vscode/                        # Editor settings
├── .claude/                        # Claude Code workspace metadata
├── .planning/                      # GSD planning outputs (codebase maps, phases)
│   └── codebase/                   # ARCHITECTURE.md, STRUCTURE.md, etc.
├── .omo/, .sisyphus/               # Tool-specific run-continuation state
│
├── nix/                            # Nix flake — primary source of truth
│   ├── flake.nix                   # Flake entry: inputs, outputs, helpers
│   ├── flake.lock                  # Pinned input commits
│   ├── Makefile                    # `make darwin|nixos|update|lint|format|clean`
│   ├── README.md                   # Nix tree usage notes
│   ├── package.json                # (npm metadata, peripheral)
│   ├── docs/                       # Supplemental Nix documentation
│   ├── lib/                        # (empty — reserved for shared helpers)
│   ├── pkgs/                       # Local Nix derivations (callPackage targets)
│   │   └── unocss-language-server.nix
│   ├── scripts/                    # (empty — reserved for build scripts)
│   ├── hosts/                      # Per-machine system configurations
│   │   ├── darwin/
│   │   │   └── Sterling-MBP/
│   │   │       ├── default.nix     # Host entry (imports common+darwin modules)
│   │   │       └── homebrew.nix    # Homebrew taps/brews/casks
│   │   └── nixos/
│   │       ├── kirby/              # Linux desktop (hyprland + KDE)
│   │       │   ├── default.nix
│   │       │   ├── boot.nix, secure-boot.nix
│   │       │   ├── hardware.nix, hardware-configuration.nix  (auto-gen)
│   │       │   ├── networking.nix, desktop.nix, openrgb.nix
│   │       │   ├── howdy.nix, packages.nix
│   │       └── wsl/
│   │           └── default.nix     # WSL-specific NixOS overrides
│   ├── modules/                    # Reusable feature modules
│   │   ├── common/                 # Cross-platform
│   │   │   ├── default.nix, apps.nix, nix-core.nix
│   │   ├── darwin/                 # nix-darwin only
│   │   │   ├── default.nix, system.nix, security.nix
│   │   ├── nixos/                  # NixOS only
│   │   │   ├── default.nix, 1password.nix, flatpak.nix,
│   │   │   ├── hyprland.nix, localsend.nix, nix-ld.nix, podman.nix
│   │   └── home/                   # Reusable home-manager modules
│   │       ├── default.nix, gui.nix
│   └── home/                       # Per-user home-manager configs
│       ├── default.nix             # Shared imports (zsh, neovim, git, packages, ai)
│       ├── zsh.nix, neovim.nix, git.nix, oh-my-posh.nix, packages.nix
│       ├── ai/                     # AI tooling (claude-code, mcp)
│       │   └── default.nix, claude-code.nix, mcp.nix
│       ├── darwin/                 # macOS overlays (ghostty-bin, gui)
│       │   └── default.nix, gui.nix, packages.nix
│       ├── nixos/                  # Linux host-specific HM
│       │   ├── kirby/              # Hyprland desktop user env
│       │   │   ├── default.nix, apps.nix, ashell.nix, hyprland.nix,
│       │   │   ├── kde.nix, packages.nix, rofi.nix, swaync.nix,
│       │   │   ├── theme.nix, tokyonight.rasi, zen-browser.nix
│       │   └── wsl/
│       │       └── default.nix
│       └── ubuntu/
│           └── default.nix         # Home-manager-only (non-Nix Ubuntu)
│
├── nvim/                           # Neovim config (LazyVim-based)
│   ├── init.lua                    # Bootstrap: require("config.lazy")
│   ├── lazyvim.json                # Enabled LazyVim extras
│   ├── lazy-lock.json              # Plugin commit pins
│   ├── stylua.toml                 # Lua formatter (2-space, 120col)
│   ├── LICENSE, README.md
│   └── lua/
│       ├── config/                 # Bootstrap + core settings
│       │   ├── lazy.lua, options.lua, keymaps.lua, autocmds.lua
│       └── plugins/                # Custom plugin specs (LazyVim overrides)
│           ├── codecompanion.lua, colorscheme.lua, cord.lua,
│           ├── example.lua, img-clip.lua, mason.lua, nil.lua,
│           ├── nixd.lua, opencode.lua, unocss.lua
│
├── sketchybar/                     # macOS status bar (Lua)
│   ├── sketchybarrc                # Daemon entry: require("helpers"), require("init")
│   ├── init.lua                    # Bar bootstrap + event loop
│   ├── bar.lua, default.lua, colors.lua, icons.lua, settings.lua
│   ├── items/                      # Bar items (apple, calendar, front_app, etc.)
│   │   ├── init.lua, apple.lua, calendar.lua, front_app.lua,
│   │   ├── media.lua, workspaces.lua
│   │   └── widgets/                # battery, cpu, volume, wifi
│   └── helpers/                    # C/Lua helper binaries + scripts
│       ├── init.lua, app_icons.lua, default_font.lua,
│       ├── install, install.sh, makefile,
│       ├── event_providers/        # cpu_load, network_load (C sources)
│       └── menus/                  # Menu helper binaries
│
├── aerospace/                      # macOS tiling WM
│   └── aerospace.toml
│
├── opencode/                       # opencode IDE/agent ecosystem
│   ├── opencode.json, tui.json, settings.json
│   ├── package.json, bun.lock
│   ├── agents/                     # GSD agent prompt definitions (.md)
│   ├── command/                    # Slash command definitions
│   ├── get-shit-done/              # GSD framework (workflows, templates, refs)
│   ├── hooks/                      # Lifecycle hooks
│   ├── plugins/                    # Plugin code
│   ├── skills/                     # Per-skill (clonedeps, codemap, simplify)
│   ├── gsd-file-manifest.json, gsd-install-state.json
│   └── gsd-migration-journal/
│
├── wallpapers/                     # Static image assets
│   └── spiderverse.jpg
│
└── archive/                        # Legacy / non-Nix artifacts
    └── Brewfile
```

## Directory Purposes

**`nix/`:**
- Purpose: Single source of truth for declarative system + user configuration
- Contains: Flake, host configs, reusable modules, home-manager configs, local packages
- Key files: `flake.nix`, `Makefile`, `home/default.nix`

**`nix/hosts/`:**
- Purpose: Per-machine system options (hostname, hardware, boot, networking)
- Contains: One subdirectory per host, grouped by platform (`darwin/`, `nixos/`)
- Key files: `darwin/Sterling-MBP/default.nix`, `nixos/kirby/default.nix`, `nixos/wsl/default.nix`

**`nix/modules/`:**
- Purpose: Reusable, composable feature modules imported by hosts/home
- Contains: `common/`, `darwin/`, `nixos/`, `home/` subtrees, each with a barrel `default.nix`
- Key files: `common/nix-core.nix`, `darwin/system.nix`, `nixos/hyprland.nix`, `home/gui.nix`

**`nix/home/`:**
- Purpose: Home Manager configuration (user environment), shared across hosts
- Contains: Shared modules at root, platform/host overlays in subdirectories
- Key files: `default.nix` (imports), `zsh.nix`, `neovim.nix`, `packages.nix`

**`nix/lib/`:**
- Purpose: Reserved for shared Nix helper functions
- Contains: Empty — helpers are currently inline in `flake.nix`

**`nix/pkgs/`:**
- Purpose: Locally-defined Nix derivations consumed via `pkgs.callPackage`
- Contains: One `.nix` file per package
- Key files: `unocss-language-server.nix`

**`nix/scripts/`:**
- Purpose: Reserved for ad-hoc build/maintenance scripts
- Contains: Empty

**`nvim/`:**
- Purpose: Neovim configuration consumed at runtime from `~/.config/nvim`
- Contains: `init.lua` entry, LazyVim plugin spec, custom plugins, lock file
- Key files: `init.lua`, `lua/config/lazy.lua`, `lua/plugins/*.lua`

**`sketchybar/`:**
- Purpose: macOS status bar definition (Lua + helper binaries)
- Contains: Bar entry, items/widgets, helpers (event providers, menus)
- Key files: `sketchybarrc`, `init.lua`, `items/init.lua`

**`aerospace/`:**
- Purpose: macOS tiling window manager config
- Contains: Single TOML file
- Key files: `aerospace.toml`

**`opencode/`:**
- Purpose: opencode IDE configuration + GSD agent framework
- Contains: agents, skills, hooks, plugins, workflows
- Key files: `opencode.json`, `agents/*.md`

**`wallpapers/`:**
- Purpose: Static desktop background assets
- Contains: Image files

**`archive/`:**
- Purpose: Legacy non-Nix artifacts kept for reference (explicitly ignored by stow)
- Contains: Pre-Nix `Brewfile`

**`.planning/codebase/`:**
- Purpose: GSD codebase maps consumed by planner/executor agents
- Contains: `ARCHITECTURE.md`, `STRUCTURE.md`, `STACK.md`, etc.

## Key File Locations

**Entry Points:**
- `nix/flake.nix`: Flake outputs (`darwinConfigurations`, `nixosConfigurations`, `formatter`)
- `nix/Makefile`: High-level developer-facing commands
- `nvim/init.lua`: Neovim startup
- `sketchybar/sketchybarrc`: Sketchybar daemon entry

**Configuration:**
- `nix/flake.lock`: Pinned input revisions (reproducibility)
- `.editorconfig`: Indentation rules
- `.stowrc`: stow target + ignores
- `nvim/lazyvim.json`: LazyVim extras list
- `nvim/lazy-lock.json`: Plugin commit pins
- `opencode/opencode.json`: opencode IDE config

**Core Logic — Flake/Host wiring:**
- `nix/flake.nix` (lines 51-149): Helper functions (`mkSystem`, `mkDarwin`, `mkHomeManagerConfig`, `mkSpecialArgs`)
- `nix/flake.nix` (lines 152-181): Output declarations

**Core Logic — Host configs:**
- `nix/hosts/darwin/Sterling-MBP/default.nix`: macOS host
- `nix/hosts/nixos/kirby/default.nix`: Linux desktop host
- `nix/hosts/nixos/wsl/default.nix`: WSL host (not wired to flake outputs)

**Core Logic — Modules:**
- `nix/modules/common/nix-core.nix`: Substituters, trusted keys, allowUnfree, fonts, zsh enable
- `nix/modules/darwin/system.nix`: macOS defaults (dock, KeyRepeat, fonts)
- `nix/modules/nixos/hyprland.nix`: Hyprland system enable
- `nix/modules/home/gui.nix`: Shared ghostty config

**Core Logic — Home Manager:**
- `nix/home/default.nix`: Shared user environment entrypoint
- `nix/home/zsh.nix`: Shell config (oh-my-zsh plugins, init content)
- `nix/home/neovim.nix`: Neovim package + LSP/formatter/linter list
- `nix/home/packages.nix`: User packages
- `nix/home/git.nix`: Git identity + defaults
- `nix/home/ai/`: claude-code + MCP server config

**Testing:**
- None. Validation = `make lint`, `make format`, dry-run rebuilds (see `CLAUDE.md:81-91`).

## Naming Conventions

**Files:**
- Nix files: `kebab-case.nix` (e.g., `nix-core.nix`, `secure-boot.nix`, `oh-my-posh.nix`, `hardware-configuration.nix`)
- Lua files: `snake_case.lua` (e.g., `front_app.lua`, `app_icons.lua`, `default_font.lua`) — plugins/options use single-word lowercase (`mason.lua`, `nixd.lua`)
- Barrel files: always `default.nix` (one per importable directory)
- Markdown docs: `UPPERCASE.md` for repo-level (`CLAUDE.md`, `AGENTS.md`, `README.md`); `kebab-case.md` for agent prompts (`opencode/agents/gsd-code-fixer.md`)
- TOML/JSON configs: lowercase (`aerospace.toml`, `opencode.json`, `lazy-lock.json`)
- Lock files: `<name>.lock` or `<name>-lock.json`

**Directories:**
- Singular, lowercase (`module`, `host`, `home`, `plugin`) — e.g., `modules/`, `hosts/`, `home/`, `plugins/`
- Hostnames preserved verbatim (`Sterling-MBP` with capitalization and hyphen, `kirby`, `wsl`)
- Platform names lowercase (`darwin/`, `nixos/`, `ubuntu/`)

**Nix attributes:**
- Mixed: per-file consistency. Mostly `camelCase` for own values, `kebab-case` for nixpkgs-derived option names (e.g., `system.defaults.dock.persistent-apps`)
- Function args destructured at the top: `{ pkgs, lib, username, hostname, inputs, pkgs-stable, ... }:`

## Where to Add New Code

**New host (e.g. another Mac):**
- System config: create `nix/hosts/darwin/<hostname>/default.nix` (and any siblings like `homebrew.nix`)
- Wire into flake: add `darwinConfigurations."<hostname>" = mkDarwin { hostname = "<hostname>"; modules = [./hosts/darwin/<hostname>]; homeImports = [./home ./home/darwin ...]; };` in `nix/flake.nix`
- Optional Makefile target: add `<hostname>:` target invoking `nh darwin switch . -H <hostname>`

**New NixOS host:**
- System config: create `nix/hosts/nixos/<hostname>/default.nix` plus `boot.nix`, `hardware-configuration.nix` (generate via `nixos-generate-config`), and any feature files
- Per-user HM: create `nix/home/nixos/<hostname>/default.nix` importing relevant modules from `../../../modules/home/`
- Wire into flake: add `nixosConfigurations."<hostname>" = mkSystem { ... }` in `nix/flake.nix:164` block style

**New reusable system module:**
- File: `nix/modules/<platform>/<feature>.nix` (where `<platform>` is `common`, `darwin`, or `nixos`)
- Register: add `./<feature>.nix` to the imports list in the sibling `default.nix`
- Consumed automatically by every host that imports that module barrel

**New reusable home module:**
- File: `nix/modules/home/<feature>.nix`
- Register: add to `nix/modules/home/default.nix` imports
- Consume from a host's HM entrypoint (e.g. `nix/home/darwin/default.nix`) via `../../modules/home/<feature>.nix`

**New shared user-level feature (all hosts):**
- File: `nix/home/<feature>.nix`
- Register: add to imports in `nix/home/default.nix`

**New host-specific user feature (e.g. kirby only):**
- File: `nix/home/nixos/kirby/<feature>.nix`
- Register: add to `nix/home/nixos/kirby/default.nix` imports

**New local Nix package:**
- File: `nix/pkgs/<package-name>.nix` (a derivation taking `{ stdenv, fetchFromGitHub, ... }`)
- Consume: in a `.nix` consumer file, `let myPkg = pkgs.callPackage ../pkgs/<package-name>.nix { }; in ...`

**New AI tooling (claude-code, MCP server):**
- File: `nix/home/ai/<service>.nix`
- Register: add to `nix/home/ai/default.nix` imports

**New Neovim plugin:**
- File: `nvim/lua/plugins/<name>.lua` (return a LazyVim plugin spec)
- Loaded automatically by lazy.nvim via the `{ import = "plugins" }` line in `nvim/lua/config/lazy.lua:23`

**New sketchybar item:**
- File: `sketchybar/items/<name>.lua`
- Register: add `require("items.<name>")` to `sketchybar/items/init.lua`

**New sketchybar widget:**
- File: `sketchybar/items/widgets/<name>.lua`
- Register: add `require("items.widgets.<name>")` to `sketchybar/items/widgets/init.lua`

**New homebrew brew/cask (Darwin):**
- Edit `nix/hosts/darwin/Sterling-MBP/homebrew.nix` and append to `brews` / `casks` / `taps` lists

## Special Directories

**`nix/lib/`:**
- Purpose: Reserved for shared Nix helper functions
- Generated: No
- Committed: Yes (empty directory)
- Note: Helpers currently live inline in `nix/flake.nix`; this is a target for refactoring

**`nix/scripts/`:**
- Purpose: Reserved for build/maintenance scripts
- Generated: No
- Committed: Yes (empty directory)

**`nix/hosts/nixos/kirby/hardware-configuration.nix`:**
- Purpose: NixOS-detected hardware (filesystems, kernel modules)
- Generated: Yes — by `nixos-generate-config`
- Committed: Yes
- Note: Do not edit manually; comments in `nix/hosts/nixos/kirby/default.nix:37-39` warn it will be overwritten

**`nix/flake.lock`:**
- Purpose: Pins every flake input commit hash for reproducibility
- Generated: Yes — by `nix flake update` / `nix flake lock`
- Committed: Yes

**`nvim/lazy-lock.json`:**
- Purpose: Pins Neovim plugin revisions (managed by lazy.nvim)
- Generated: Yes — by `:Lazy update`
- Committed: Yes

**`.planning/`:**
- Purpose: GSD planning artifacts (codebase maps, phase plans)
- Generated: Yes — by GSD agent commands
- Committed: Variable (`.planning/codebase/` is typically committed)

**`.omo/`, `.sisyphus/`:**
- Purpose: Tool-specific run state for omo and sisyphus utilities
- Generated: Yes
- Committed: Typically not — but `run-continuation` subdirs are present in working tree

**`opencode/node_modules/`:**
- Purpose: Bun-installed JS dependencies for opencode plugins
- Generated: Yes — by `bun install`
- Committed: No (gitignored)

**`archive/`:**
- Purpose: Pre-Nix artifacts retained for reference
- Generated: No
- Committed: Yes
- Note: Explicitly ignored by stow (`.stowrc:--ignore='^archive$'`)

**`wallpapers/`:**
- Purpose: Static image assets referenced by desktop config
- Generated: No
- Committed: Yes

---

*Structure analysis: 2026-05-26*
