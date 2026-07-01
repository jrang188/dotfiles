# nvim/

## Responsibility

Root directory of the Neovim user configuration. Owns the LazyVim framework bootstrap, Lua formatting rules, enabled feature extras manifest, and plugin lockfile. Serves as the entry point (`init.lua`) that Neovim reads on startup.

## Design

- **Framework**: LazyVim — a preconfigured Neovim distribution built on lazy.nvim. Provides sensible defaults and a plugin-spec pattern where every file under `lua/plugins/` returning a list of plugin specs is auto-loaded.
- **Extras-driven configuration**: `lazyvim.json` declares 36 curated LazyVim extras that enable language support, editor features, formatting, linting, debugging, and testing. Extras are imported by the LazyVim core spec (`"lazyvim.plugins.extras.*"`).
- **Formatter**: `stylua.toml` enforces 2-space indentation and 120-column line width for all Lua files.
- **Lockfile**: `lazy-lock.json` pins plugin commits for reproducible installations across machines.
- **LSP integration**: `.neoconf.json` enables neodev library annotations and lua_ls integration for Neovim plugin development.

## Flow

1. Neovim starts and sources `init.lua`.
2. `init.lua` delegates immediately to `require("config.lazy")`, which bootstraps lazy.nvim and invokes the LazyVim setup.
3. LazyVim loads the plugin spec list: first the LazyVim core (`"LazyVim/LazyVim"` with `import = "lazyvim.plugins"`), then the extras from `lazyvim.json` (imported internally), then every spec file under `lua/plugins/`.
4. Each plugin spec file returns a LazyVim specification table — a list of plugin spec tables following the lazy.nvim schema.
5. Plugins are installed, loaded lazily or eagerly per their spec configuration, and configured via `opts`, `config`, `init`, and `keys` fields.

## Integration

- **Entry contract**: `init.lua` → `lua/config/lazy.lua` → lazy.nvim bootstrap
- **Plugin registry**: `lazy-lock.json` records every installed plugin commit hash
- **Formatter**: `stylua.toml` consumed by stylua CLI (run from repo root: `stylua lua/`)
- **LSP**: `.neoconf.json` consumed by neoconf.nvim on startup to configure lua_ls
- **Extras manifest**: `lazyvim.json` read by the LazyVim core spec loader; paths are relative to `lazyvim.plugins.extras.*`
