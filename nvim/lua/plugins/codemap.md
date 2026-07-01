# nvim/lua/plugins/

## Responsibility

Houses all custom plugin specifications and LazyVim plugin overrides. Every `.lua` file in this directory returns a LazyVim plugin spec table — a list of specification objects that lazy.nvim merges with the LazyVim core specs. This is the primary extension point for adding new plugins, modifying existing LazyVim-bundled plugin configs, or disabling bundled plugins.

## Design

- **Spec format per file**: Each file returns a Lua list (table with integer keys). Each element is a LazyVim plugin spec with this schema:
  ```lua
  {
    "plugin/name",               -- required: plugin URL or short name
    enabled = true|false,        -- disable a bundled plugin
    opts = {...},                -- declarative options (merged with parent specs)
    opts = function(_, opts) end,-- functional option extension
    config = function() end,     -- imperative setup (replaces opts merge)
    init = function() end,       -- eager setup before plugin loads
    event = "EventName",         -- lazy-load trigger
    keys = { ... },              -- lazy-load keymaps
    dependencies = { ... },      -- plugin prerequisites
    version = "^X.Y.Z",         -- semver constraint
    build = "command",           -- post-install hook
  }
  ```
- **Auto-discovery**: lazy.nvim discovers all files via `{ import = "plugins" }` in `lazy.lua`. The module prefix is `lua/plugins/`; filenames map directly to `require` paths (e.g., `lua/plugins/cord.lua` → `require("plugins.cord")`).
- **Spec merging**: LazyVim uses `vim.tbl_deep_extend` to merge user `opts` with parent (LazyVim-core) specs. Functional `opts` receive the parent config as the second argument.

### Plugin inventory

| File | Plugin(s) configured | Purpose |
|------|---------------------|---------|
| `colorscheme.lua` | `LazyVim/LazyVim` | Overrides colorscheme to `tokyonight-night` |
| `codecompanion.lua` | `olimorris/codecompanion.nvim` | AI coding assistant with custom adapters (Anthropic-based minimax via opencode.ai, opencode chat), CLI agent integration, keymaps |
| `cord.lua` | `vyfor/cord.nvim` | Discord Rich Presence integration, build step via `:Cord update` |
| `example.lua` | (multiple, disabled) | Disabled reference spec demonstrating LazyVim patterns (adding plugins, overriding opts, disabling, extending) |
| `img-clip.lua` | `HakonHarnes/img-clip.nvim` | Paste images from system clipboard into markdown, base64-free, drag-and-drop support |
| `mason.lua` | `mason-org/mason-lspconfig.nvim`, `mason-org/mason.nvim` | Disables both mason-lspconfig and mason.nvim entirely (no auto-LSP-install) |
| `nil.lua` | `neovim/nvim-lspconfig` | Disables `nil_ls` LSP server |
| `nixd.lua` | `neovim/nvim-lspconfig` | Configures nixd LSP with flake-based system and home-manager options evaluation using `builtins.getFlake` |
| `opencode.lua` | `nickjvandyke/opencode.nvim` | OpenCode AI provider integration, snacks.nvim dependency for input/picker/terminal, keymaps for ask/select/toggle/operator, scroll fix for native `<C-a>`/`<C-x>` |
| `unocss.lua` | `neovim/nvim-lspconfig` | Registers `unocss` LSP server |
| `vim-tmux-navigator.lua` | `christoomey/vim-tmux-navigator` | Seamless Neovim<->tmux pane navigation via Ctrl-h/j/k/l, lazy-loaded on commands and keys |

### Detailed per-file documentation

**`colorscheme.lua`** — Overrides `LazyVim/LazyVim` opts to set `colorscheme = "tokyonight-night"`. This is the standard LazyVim mechanism for choosing a colorscheme: setting it on the LazyVim meta-plugin rather than calling `vim.cmd.colorscheme` directly.

**`codecompanion.lua`** — Configures `olimorris/codecompanion.nvim` v19 with:
- A custom adapter `"minimax"` extending the `"anthropic"` adapter, routing to `https://opencode.ai/zen/go/v1/messages` with the API key fetched from 1Password CLI.
- Interaction routing: `chat` → `"opencode"` adapter, `cmd`/`inline` → `"minimax"` adapter.
- CLI agents: `claude_code` (`claude` command) and `opencode` (`opencode` command), both terminal-based.
- Keymaps: `<C-a>` (actions), `<LocalLeader>a` (toggle chat), `ga` (add to chat), cab abbreviation `cc` → `CodeCompanion`.

**`cord.lua`** — Basic Declaration for `vyfor/cord.nvim` with a `build = ":Cord update"` hook. No `opts` configured (commented-out log_level trace).

**`example.lua`** — Disabled via `if true then return {} end` guard. Serves as a reference catalog demonstrating all major LazyVim spec patterns:
- Adding a plugin: `{ "ellisonleao/gruvbox.nvim" }`
- Changing LazyVim opts: `{ "LazyVim/LazyVim", opts = { colorscheme = "gruvbox" } }`
- Overriding plugin opts: `{ "folke/trouble.nvim", opts = { ... } }`
- Disabling a plugin: `{ "folke/trouble.nvim", enabled = false }`
- Extending dependencies: `{ "hrsh7th/nvim-cmp", dependencies = { "hrsh7th/cmp-emoji" } }`
- Adding keymaps: `{ "nvim-telescope/telescope.nvim", keys = { { "<leader>fp", ... } } }`
- Registering LSP servers: `{ "neovim/nvim-lspconfig", opts = { servers = { pyright = {} } } }`
- Combining LSP with external setup (typescript.nvim): `{ "neovim/nvim-lspconfig", dependencies = { "jose-elias-alvarez/typescript.nvim" }, opts = { setup = { tsserver = ... } } }`
- Changing treesitter parsers: `{ "nvim-treesitter/nvim-treesitter", opts = { ensure_installed = { ... } } }`
- Overriding lualine: `{ "nvim-lualine/lualine.nvim", opts = function(_, opts) ... end }`
- Importing LazyVim extras inline: `{ import = "lazyvim.plugins.extras.lang.typescript" }`
- Mason tool installation: `{ "williamboman/mason.nvim", opts = { ensure_installed = { "stylua", ... } } }`

**`img-clip.lua`** — Configures `HakonHarnes/img-clip.nvim` with:
- `event = "VeryLazy"` — loads after startup.
- `opts`: base64 embedding disabled, no filename prompts, insert-mode drag-and-drop, absolute paths.
- `keys`: `<leader>p` → `:PasteImage`.

**`mason.lua`** — Two specs, both with `enabled = false`: `mason-org/mason-lspconfig.nvim` (prevents auto-installing LSP servers) and `mason-org/mason.nvim` (removes the mason UI and management entirely). LSP servers are expected to be installed externally.

**`nil.lua`** — Targets `neovim/nvim-lspconfig` with `opts.servers.nil_ls.enabled = false`. Disables the Nix LSP server `nil_ls`.

**`nixd.lua`** — Configures `nixd` LSP (via `neovim/nvim-lspconfig`) with flake-aware options evaluation. Dynamically computes two Nix expressions at startup:
- `system_options_expr`: evaluates `builtins.getFlake ~/dotfiles/nix` to extract either `darwinConfigurations.<hostname>.options` or `nixosConfigurations.<hostname>.options` depending on platform.
- `home_options_expr`: evaluates the same flake to find `homeConfigurations."<user>@<hostname>"` (with fallbacks).
- The hostname is detected at runtime via `vim.loop.os_gethostname()`, username from `$USER`.
- Sets `nixd` formatting command to `nixfmt`.

**`opencode.lua`** — Configures `nickjvandyke/opencode.nvim` with:
- `dependencies`: `folke/snacks.nvim` with `input`, `picker`, and `terminal` opts (required for `snacks` provider).
- `config` (imperative): sets `vim.g.opencode_opts`, enables `autoread`, registers keymaps.
- Keymaps:
  - `<C-a>` → `opencode.ask("@this: ", { submit = true })` (normal/visual)
  - `<C-x>` → `opencode.select()` (normal/visual)
  - `<C-.>` → `opencode.toggle()` (normal/terminal)
  - `go` → `opencode.operator("@this ")` (expr, normal/visual)
  - `goo` → `opencode.operator("@this ")` with suffix (expr, normal)
  - `<S-C-u>` / `<S-C-d>` → scroll half-page up/down (normal)
  - `+` / `-` → remaps native `<C-a>`/`<C-x>` increment/decrement (normal, avoids conflict)

**`unocss.lua`** — Targets `neovim/nvim-lspconfig` with `opts.servers.unocss = {}`. Registers the UnoCSS LSP server for Tailwind-like utility class support.

**`vim-tmux-navigator.lua`** — Configures `christoomey/vim-tmux-navigator` for seamless navigation between Neovim splits and tmux panes. Lazy-loaded via:
- `cmd`: `TmuxNavigateLeft`, `TmuxNavigateDown`, `TmuxNavigateUp`, `TmuxNavigateRight`, `TmuxNavigatePrevious`, `TmuxNavigatorProcessList`.
- `keys`: `<C-h>` (left), `<C-j>` (down), `<C-k>` (up), `<C-l>` (right), `<C-\>` (previous pane).
- Keymaps use `"<cmd><C-U>TmuxNavigate*<cr>"` pattern allowing count-prefixed navigation from visual mode.
- Pairs with the tmux-side `vim-tmux-navigator` tmux plugin configured in `nix/home/tmux.nix`.

## Flow

1. `lazy.lua` calls `require("lazy").setup({ spec = { { import = "plugins" } } })`.
2. lazy.nvim scans `lua/plugins/` for all `*.lua` files, requires each, and expects a list of plugin specs.
3. Each spec table is processed by LazyVim's plugin loader, which merges user `opts` with the LazyVim default specs (if the plugin exists in the core).
4. Plugins marked with `enabled = false` are omitted from the load set.
5. For enabled plugins, lazy.nvim applies loading strategies based on `event`, `keys`, `cmd`, `ft`, or eager loading (default).
6. During load: `init` fires first (eagerly at spec processing time), then `opts` are merged and passed to the plugin's `config` function, or a custom `config` replaces the merge entirely.

## Integration

- **Called by**: `lazy.lua` via `require("lazy").setup({ spec = { { import = "plugins" } } })`
- **Depends on**: LazyVim core specs at `lazyvim.plugins` (provides default `opts` for plugins that are overridden here)
- **Depends on**: lazy.nvim for spec discovery, loading, and merging
- **Cross-file references**:
  - `nixd.lua` reads `~/dotfiles/nix` flake path and environment variables (`$USER`, hostname)
  - `codecompanion.lua` calls `op` CLI for API key retrieval (1Password)
  - `opencode.lua` depends on `folke/snacks.nvim` (input, picker, terminal modules)
  - `example.lua` references `lazyvim.plugins.extras.lang.typescript` import
- **Interaction with other config modules**:
  - `lazy.lua` sets the install colorscheme fallback to `tokyonight` which matches `colorscheme.lua`'s override
  - `options.lua` clipboard settings are consumed by all plugins that interact with system clipboard
