# Coding Conventions

**Analysis Date:** 2026-05-26

## Naming Patterns

**Files:**
- Nix files: `kebab-case.nix` (e.g., `nix-core.nix`, `hardware-configuration.nix`, `secure-boot.nix`, `zen-browser.nix`)
- Single-purpose Nix modules use a single lowercase word (e.g., `git.nix`, `zsh.nix`, `neovim.nix`, `packages.nix`)
- Lua files: `snake_case.lua` for helpers (e.g., `default_font.lua`, `app_icons.lua`) and `lowercase.lua` for top-level config (e.g., `bar.lua`, `colors.lua`, `init.lua`)
- Lua plugin spec files: single lowercase word matching the plugin or tool (e.g., `codecompanion.lua`, `mason.lua`, `opencode.lua`)
- Hosts named by hostname (e.g., `Sterling-MBP`, `kirby`, `wsl`)
- JS hook scripts: `gsd-<kebab-case>.js` (e.g., `gsd-statusline.js`, `gsd-prompt-guard.js`) in `opencode/hooks/`
- Test files: `<name>.test.ts` co-located with the implementation file (single example: `opencode/skills/codemap/scripts/codemap.test.ts`)

**Functions:**
- Nix: lowercase `camelCase` with `mk` prefix for builder helpers (e.g., `mkSpecialArgs`, `mkHomeManagerConfig`, `mkSystem`, `mkDarwin`, `mkStablePkgs`, `getStableNixpkgs`) — see `nix/flake.nix`
- Lua: `snake_case` for local helpers, dotted module access for sketchybar API (e.g., `sbar.add`, `sbar.bar`, `sbar.begin_config`)
- JS: `camelCase` (e.g., `readGsdConfig`, `getConfigValue`, `readLastSlashCommand`) — see `opencode/hooks/gsd-statusline.js`
- TS/MJS exports: `camelCase` for functions, `PascalCase` for classes (e.g., `PatternMatcher`, `computeFileHash`, `selectFiles`) — see `opencode/skills/codemap/scripts/codemap.mjs`

**Variables:**
- Nix: `camelCase` for `let`-bound values (`homeDirectory`, `darwinSystem`, `nixosSystem`, `unocss-language-server`)
- Nix attribute keys: `camelCase` for nix-flake/HM options (`stateVersion`, `defaultUserShell`, `useGlobalPkgs`, `enableZshIntegration`), `kebab-case` for upstream-spelled keys (`auto-optimise-store`, `trusted-public-keys`, `nix-direnv`, `extra-substituters`)
- Lua: `snake_case` (`flake_path`, `is_darwin`, `system_options_expr`)

**Types:**
- TS: `PascalCase` classes (`PatternMatcher`)
- JS: Module-level uppercase constants (`VERSION`, `STATE_DIR`, `STATE_FILE`, `CODEMAP_FILE`) — see `opencode/skills/codemap/scripts/codemap.mjs`

## Code Style

**Formatting:**
- Nix: `nixfmt` / `nixfmt-tree` (via `treefmt`) — invoked by `make format` or `nix fmt` from `nix/Makefile`
- Lua (Neovim): `stylua` — config at `nvim/stylua.toml` (2-space indent, 120 column width)
- Lua (sketchybar): mixed tabs/spaces present in `sketchybar/helpers/app_icons.lua` (not auto-formatted)
- General: `.editorconfig` at `nix/.editorconfig` enforces `lf`, final newline, UTF-8, trim trailing whitespace
- `.editorconfig` per-extension: `*.nix` → 2 spaces; `*.sh` → 2 spaces; `Makefile` → tabs; `*.md` → no trim trailing whitespace

**Linting:**
- Nix: `statix check .` — invoked by `make lint` and via pre-commit hook `statix-check` in `nix/.pre-commit-config.yaml`
- Pre-commit hooks (in `nix/.pre-commit-config.yaml`):
  - `nixfmt-tree` — formats `*.nix` files via `treefmt`
  - `statix-check` — lints `*.nix` files
  - `trailing-whitespace`, `end-of-file-fixer` — limited to `*.nix`
  - `check-yaml`, `check-json` — excluding `flake.lock`/`*.lock`

## Import Organization

**Nix file header pattern:**
```nix
{ pkgs, ... }:                          # function arg destructure (Home Manager / module style)
{
  imports = [ ./foo.nix ./bar.nix ];     # local file imports first
  ...
}
```

**Nix import order in `default.nix`** (observed in `nix/home/default.nix`, `nix/hosts/nixos/kirby/default.nix`):
1. Cross-platform shared modules (`../../../modules/common`)
2. Platform modules (`../../../modules/darwin`, `../../../modules/nixos`)
3. Host- or environment-specific modules (local `./*.nix` files)
4. Generated/auto files last with a comment (e.g., `./hardware-configuration.nix` in `nix/hosts/nixos/kirby/default.nix`)

**Lua import order (Neovim plugin specs):**
- Single `return { ... }` table, no top-level requires for plugin specs
- `require("config.lazy")` is the only call in `nvim/init.lua`
- Sketchybar entry `sketchybar/init.lua` calls `require()` in render order: `bar` → `default` → `items`

**JS imports (opencode hooks):**
- CommonJS only — `const fs = require('fs')` style (project marks `"type":"commonjs"` in `opencode/package.json`)
- Node core modules grouped at top

**TS/MJS imports (codemap):**
- ESM with `from 'node:fs'` / `from 'node:path'` prefix for built-ins
- Local imports use relative paths with `.mjs` extension explicitly (`await import('./codemap.mjs')`)
- Test file uses `bun:test` for the runner imports

**Path Aliases:**
- None — relative paths everywhere
- Nix paths use `../../../modules/...` to walk up to shared modules

## Error Handling

**Nix:**
- `lib.mkDefault` / `lib.mkIf` / `lib.mkMerge` preferred over inline conditionals (see `nix/hosts/nixos/wsl/default.nix` uses `lib.mkDefault`)
- Conditional logic via `if/then/else` inside `let` bindings for platform branching (see `nix/home/default.nix` for `homeDirectory` selection)
- Overlays used to pin or substitute packages with inline comments explaining the workaround (see `nix/hosts/nixos/kirby/default.nix` hyprland pin, `nix/modules/darwin/default.nix` pre-commit pin)

**JS hooks:**
- `try/catch` around every filesystem read; failure returns a safe default (`{}` or `null`) rather than throwing — see `readGsdConfig` and `readLastSlashCommand` in `opencode/hooks/gsd-statusline.js`
- Empty `catch {}` blocks for best-effort reads (see `computeFileHash` in `opencode/skills/codemap/scripts/codemap.mjs`)

**Lua:**
- Conditional `if not vim.g.vscode then ... end` guards in `nvim/lua/config/options.lua`
- `vim.api.nvim_echo` + `os.exit(1)` for fatal bootstrap errors in `nvim/lua/config/lazy.lua`

## Logging

**Framework:** `console.log` in JS scripts (e.g., `opencode/skills/codemap/scripts/codemap.mjs` logs migration events)

**Patterns:**
- Print one-line user-facing notices for migrations and state transitions
- No leveled logger; statusline hooks emit structured strings consumed by Claude Code's statusline UI
- Nix activation scripts use shell `echo` inline (see `nix/modules/darwin/system.nix` `activationScripts.UserActivation`)

## Comments

**When to Comment:**
- Section dividers in long package lists using `# ============================================` banners — see `nix/home/packages.nix`, `nix/home/ubuntu/default.nix`, `nix/modules/common/apps.nix`
- Per-package inline comments explaining purpose (e.g., `nil # Nix language server`)
- Overlay/workaround blocks always carry a "why" comment with an upstream issue link (see `nix/hosts/nixos/kirby/default.nix` and `nix/modules/darwin/default.nix`)
- Multi-line `###` banners around major config sections in host files (see `nix/hosts/darwin/Sterling-MBP/default.nix`, `nix/modules/darwin/system.nix`)
- LazyVim defaults referenced by URL in stub files (`nvim/lua/config/options.lua`, `nvim/lua/config/autocmds.lua`)

**JSDoc/TSDoc:**
- JSDoc block comments on JS helper functions describing intent and return value (see `opencode/hooks/gsd-statusline.js` for `readGsdConfig`, `readLastSlashCommand`)
- No formal JSDoc on TS file — relies on TypeScript types

## Function Design

**Size:** Small, single-purpose helpers. Most JS/TS functions ≤ 30 lines. Largest is `selectFiles`/`walkFiles` (≈30 lines combined) in `opencode/skills/codemap/scripts/codemap.mjs`.

**Parameters:**
- Nix: prefer attribute-set destructure `{ pkgs, lib, ... }:` over positional args
- Builder helpers in `nix/flake.nix` use named attribute parameters with defaults (`extraArgs ? { }`)
- JS: positional parameters with sensible defaults via short-circuit logic (no destructured option bags)

**Return Values:**
- Nix functions return attribute sets representing modules
- JS helpers return either the requested value or a safe sentinel (`null`, `{}`)
- TS exports are pure functions returning new objects/arrays

## Module Design

**Exports:**
- Nix: a single attribute set per file (the module's options/imports). Sub-modules accessed via `imports = [ ./foo.nix ];`
- Lua plugin specs: each file returns one plugin table (`return { ... }`); aggregated by lazy.nvim's auto-import
- JS hooks: scripts are self-executing — no `module.exports` needed
- MJS: explicit `export const` / `export class` / `export function`

**Barrel Files:**
- Nix `default.nix` acts as a barrel — re-exports via `imports = [ ./a.nix ./b.nix ];` (see `nix/modules/common/default.nix`, `nix/home/ai/default.nix`, `nix/modules/darwin/default.nix`)
- Sketchybar `items/init.lua` and `helpers/init.lua` aggregate via `require()`
- No barrel files in JS/TS code

## Nix-Specific Conventions

**Function arg patterns:**
- `_:` — module takes no arguments (`nix/home/git.nix`, `nix/modules/common/default.nix`)
- `{ pkgs, ... }:` — most common; ignores unused special args
- `{ username, pkgs, ... }:` / `{ username, hostname, ... }:` — host modules destructure injected specialArgs

**Attribute grouping:**
- Use `programs.foo = { enable = true; ... }` blocks rather than dotted assignments (see `nix/home/zsh.nix`, `nix/home/oh-my-posh.nix`)
- Group related sub-options under a parent attribute set (see `nix/home/default.nix` `programs.nh.clean`)

**Package list style:**
- `home.packages = with pkgs; [ ... ]` then optional `++ [ inputs.foo.packages.${system}.bar ]` for non-`pkgs` entries (see `nix/home/packages.nix`)
- Categories separated by banner comments
- One package per line with trailing inline comment

**Platform branching:**
- System detection via `pkgs.stdenv.hostPlatform.system` or `pkgs.stdenv.hostPlatform.isLinux`/`isDarwin`
- Branching done via `let homeDirectory = if ... then ... else ...;` rather than `lib.mkIf` for value selection
- Module-level enables use `lib.mkIf` when conditional

**Overlays:**
- Inline overlays use `(final: prev: { inherit (otherPkgs) name; })` pattern (see `nix/hosts/nixos/kirby/default.nix`, `nix/modules/darwin/default.nix`)
- Always documented with reason + upstream link

---

*Convention analysis: 2026-05-26*
