# nvim/lua/config/

## Responsibility

Global Neovim configuration overrides for the LazyVim distribution. Contains exactly four files, each overriding a specific domain: lazy.nvim bootstrap and plugin setup (`lazy.lua`), editor options (`options.lua`), keymaps (`keymaps.lua`), and autocommands (`autocmds.lua`). These files are loaded by LazyVim's standard entry chain.

## Design

- **Single-responsibility per file**: Each file handles exactly one configuration domain, mirroring the structure of LazyVim's own defaults at `lazyvim/config/`.
- **Declarative over imperative**: Prefers `vim.opt` and `vim.keymap.set` calls; avoids ad-hoc Lua logic.
- **Lazy loading convention**: By LazyVim convention, `options.lua` runs before lazy.nvim startup. `keymaps.lua` and `autocmds.lua` are loaded on the `VeryLazy` event (after all plugins). This is wired internally by LazyVim, not explicitly in these files.

### File inventory

| File | Responsibility | Load timing |
|------|---------------|-------------|
| `lazy.lua` | bootstrap lazy.nvim, configure plugin spec, disable bundled runtime plugins | Eager — sourced directly from `init.lua` |
| `options.lua` | override `vim.opt` settings (winbar, clipboard) | Pre-bootstrap — auto-loaded by LazyVim |
| `keymaps.lua` | custom key mappings (currently empty) | `VeryLazy` event — auto-loaded by LazyVim |
| `autocmds.lua` | custom autocommands (currently empty) | `VeryLazy` event — auto-loaded by LazyVim |

### `lazy.lua` — LazyVim bootstrap and plugin setup

- Clones lazy.nvim to `stdpath("data")/lazy/lazy.nvim` if not present, pinning to the `stable` branch.
- Prepends lazy.nvim to the runtimepath.
- Calls `require("lazy").setup({...})` with:
  - **`spec`**: imports LazyVim core (`"lazyvim.plugins"`) and local plugins (`"plugins"`)
  - **`defaults`**: `lazy = false` (custom plugins load at startup, not lazily), `version = false` (track git HEAD)
  - **`install`**: fallback colorschemes `tokyonight` and `habamax`
  - **`checker`**: periodic update checks enabled, notifications suppressed
  - **`performance.rtp.disabled_plugins`**: disables 5 built-in runtime plugins (`gzip`, `tarPlugin`, `tohtml`, `tutor`, `zipPlugin`)

### `options.lua` — Editor option overrides

- Guards against VSCode Neovim (`vim.g.vscode`): sets `vim.opt.winbar` to `"%=%m %f"` (file path centered in winbar).
- Sets `vim.opt.clipboard = "unnamedplus"` — system clipboard integration to the `+` register.

### `keymaps.lua` — Keymap overrides

- Currently empty (LazyVim defaults from `lazyvim/config/keymaps.lua` are used as-is).
- Intended for adding custom mappings in the same format: `vim.keymap.set(mode, lhs, rhs, opts)`.

### `autocmds.lua` — Autocommand overrides

- Currently empty (LazyVim defaults from `lazyvim/config/autocmds.lua` are used as-is).
- Intended for adding custom `vim.api.nvim_create_autocmd` calls.

## Flow

1. `nvim/init.lua` → `require("config.lazy")` → `lazy.lua` executes immediately.
2. `lazy.lua` bootstraps lazy.nvim and configures the spec list. LazyVim's internals then:
   - Source `options.lua` (automatic, before plugin load).
   - Initialize lazy.nvim plugin loading.
   - On `VeryLazy` event: source `keymaps.lua` and `autocmds.lua`.

## Integration

- **Consumed by**: `nvim/init.lua` (calls `require("config.lazy")`)
- **Depends on**: LazyVim framework at `lazyvim/config/options.lua`, `lazyvim/config/keymaps.lua`, `lazyvim/config/autocmds.lua` — these files add to / override those defaults
- **References**:
  - `options.lua` reads `vim.g.vscode` (guards winbar)
  - `lazy.lua` writes `vim.opt.rtp` (prepends lazy.nvim path)
  - `lazy.lua` calls `require("lazy").setup(...)` which triggers the entire plugin-loading pipeline
- **Performance**: `lazy.lua` disables 5 built-in runtime plugins to reduce startup overhead
