---
title: Conventions
last_mapped: 2026-05-26
---

# Conventions

## Nix Code Style

### Indentation & Formatting

- **2 spaces** for all `.nix` files (enforced by `.editorconfig` and `nixfmt`)
- **LF line endings** universally
- **Trailing newline** on all files
- **No trailing whitespace**
- Formatting enforced by `nixfmt` / `nixfmt-tree` (run via `nix fmt` or `make format`)

### Function Arguments

```nix
# Prefer destructuring with explicit args + catch-all
{ pkgs, username, hostname, ... }:

# Use underscore for ignored single-arg
_: { ... }
```

### Let Bindings

```nix
# Use let for intermediate values and inherit
let
  inherit (pkgs.stdenv.hostPlatform) system;
  homeDirectory = if system == "aarch64-darwin" then "/Users/${username}" else "/home/${username}";
in { ... }
```

### Attribute Sets

```nix
# Semicolons terminate every attribute — no trailing comma
{
  option1 = true;
  option2 = {
    key = "value";
  };
}
```

### Conditional Logic

```nix
# Use lib.mkIf for conditional options
services.foo.enable = pkgs.stdenv.hostPlatform.isLinux;

# Inline if for simple string/value selection
homeDirectory = if isDarwin then "/Users/${username}" else "/home/${username}";
```

### Package Lists

Group packages by category with comment headers in `packages.nix`:

```nix
home.packages =
  with pkgs;
  [
    # ============================================
    # Category Name
    # ============================================
    package1
    package2
  ]
  ++ with pkgs;
  [
    # ============================================
    # Another Category
    # ============================================
    package3
  ];
```

### Comments

- Single-line `#` comments for section headers and non-obvious config
- Multi-line block headers use `#############################################################` separator (seen in system config files)
- Inline comments on same line for brief clarifications

---

## Module Structure Conventions

### Every directory has a `default.nix`

Entry point for each module directory. Imports sibling `.nix` files:

```nix
_: {
  imports = [
    ./foo.nix
    ./bar.nix
  ];
}
```

### Import ordering in `default.nix`

1. Shared/cross-platform modules first
2. Platform-specific modules second
3. Feature modules last

Example from `nix/home/default.nix`:
```nix
imports = [
  ./zsh.nix       # shared
  ./neovim.nix    # shared
  ./git.nix       # shared
  ./packages.nix  # shared
  ./ai            # shared (directory)
];
```

### Home Manager program patterns

```nix
# Enable + configure together
programs.git = {
  enable = true;
  settings = { ... };
};

# Simple enable
programs.home-manager.enable = true;
services.foo.enable = true;
```

---

## File Naming

| Type | Convention | Examples |
|---|---|---|
| Nix config files | `kebab-case.nix` | `claude-code.nix`, `nix-core.nix`, `oh-my-posh.nix` |
| Feature directories | `kebab-case/` | `home-manager/`, `nixos/` |
| Host directories | Exact hostname | `Sterling-MBP/`, `kirby/` |
| Auto-generated | Descriptive | `hardware-configuration.nix` |

---

## Flake Helper Function Conventions

Helper functions in `flake.nix` use `mk` prefix:

```nix
mkSpecialArgs   # builds specialArgs attribute set
mkHomeManagerConfig  # wraps home-manager config
mkSystem        # creates NixOS system configuration
mkDarwin        # creates nix-darwin configuration
mkStablePkgs    # resolves correct stable nixpkgs for system
```

---

## Nixpkgs Configuration

Global nixpkgs settings in `nix/modules/common/nix-core.nix`:

```nix
nixpkgs.config = {
  allowUnfree = true;   # permits non-free packages globally
  allowBroken = true;   # permits broken packages globally
};
```

---

## Makefile Conventions

- Uses `nh` (Nix Helper) instead of raw `darwin-rebuild` / `nixos-rebuild`
- Targets: `darwin`, `nixos`, `clean`, `update`, `lint`, `format`/`fmt`
- All targets declared `.PHONY`
- Tabs required (Makefile syntax)

---

## Lua (Neovim) Conventions

From `nvim/stylua.toml`:
- **2-space indent**
- **120 column width**
- Formatter: `stylua`

---

## JavaScript / Bash (Hooks)

Located in `opencode/hooks/` and referenced from `claude/settings.json`:
- CommonJS format (`.cjs`, or `.js` with `{"type":"commonjs"}` in `package.json`)
- Bash hooks use `.sh` extension

---

## Pre-commit Hooks

Configured in `nix/.pre-commit-config.yaml`. Runs on all staged `.nix` files:

1. `nixfmt-tree` — formats via `treefmt`
2. `statix-check` — lints via `statix check .`
3. `trailing-whitespace` — removes trailing whitespace
4. `end-of-file-fixer` — ensures trailing newline
5. `check-yaml` — validates YAML syntax
6. `check-json` — validates JSON syntax

Install with `pre-commit install` from `nix/`.

---

## Gitignore Patterns

Top-level `.gitignore` via opencode's `.gitignore`:
- `node_modules/`

`claude/.gitignore` excludes runtime state:
- `agents/`, `get-shit-done/`, `hooks/`, `skills/`, `plugins/` (tool-installed)
- `backups/`, `cache/`, `sessions/`, `transcripts/`, `history.jsonl` (runtime)
