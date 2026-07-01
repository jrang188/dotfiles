# nvim/lua/

## Responsibility

Contains all custom Neovim configuration Lua modules. Houses two submodules: `config/` for global configuration overrides (lazy.nvim setup, options, keymaps, autocmds) and `plugins/` for LazyVim plugin spec files. There is no `lua/init.lua` — the folder acts purely as a namespace root for the `config` and `plugins` modules.

## Design

- **Convention-over-configuration**: LazyVim auto-discovers plugin spec files under `lua/plugins/` via `require("lazy").setup({ spec = { { import = "plugins" } } })`. Every `.lua` file in that directory returning a list of spec tables is loaded automatically.
- **Module structure**: Two subdirectories, each with a distinct responsibility:
  - `lua/config/` — bootstrap and global overrides (options, keymaps, autocmds)
  - `lua/plugins/` — individual plugin specifications and overrides
- **LazyVim spec pattern**: Each plugin spec is a Lua table following the lazy.nvim schema with LazyVim conventions: plugin URL as first element, `opts` for declarative configuration merged with parent specs, `config` for imperative setup, `init` for early eager hooks, `keys` for lazy keybinding, `event` for lazy loading, `dependencies` for plugin requirements, and `enabled = false` to disable a bundled plugin.

## Flow

1. `init.lua` (in nvim root) calls `require("config.lazy")`.
2. `lazy.lua` bootstraps lazy.nvim, then calls `require("lazy").setup(...)` with:
   - `{ "LazyVim/LazyVim", import = "lazyvim.plugins" }` — loads LazyVim's core specs
   - `{ import = "plugins" }` — loads every file in `lua/plugins/`
3. LazyVim's internal loader evaluates each plugin spec table, merging user `opts` with defaults.
4. Files in `lua/config/` are loaded eagerly by `lazy.lua` or via the `VeryLazy` event:
   - `options.lua` — applied before lazy.nvim startup (automatic by LazyVim convention)
   - `keymaps.lua` — loaded on `VeryLazy`
   - `autocmds.lua` — loaded on `VeryLazy`

## Integration

- **Called by**: `nvim/init.lua` → `require("config.lazy")`
- **Consumes**: `lazyvim.json` extras manifest (read by LazyVim core loader)
- **Consumer of**: `stylua.toml` (formatting rules for Lua source files)
- **Module paths**:
  - `require("config.lazy")` → `lua/config/lazy.lua`
  - `require("config.options")` → `lua/config/options.lua`
  - `require("config.keymaps")` → `lua/config/keymaps.lua`
  - `require("config.autocmds")` → `lua/config/autocmds.lua`
  - `require("plugins")` → aggregate of `lua/plugins/*.lua`
