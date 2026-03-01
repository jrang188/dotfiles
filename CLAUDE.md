
# CLAUDE.md - Agent Guidelines for This Repository

This repository contains Nix-based system configurations for macOS (Darwin), NixOS, and Ubuntu (WSL). It uses Nix flakes with Home Manager for declarative, reproducible system configuration.

## Repository Structure

```
.
├── nix/                    # Main Nix configuration
│   ├── flake.nix           # Flake entry point
│   ├── Makefile            # Build commands
│   ├── home/               # Home Manager configs (shared across all systems)
│   ├── hosts/              # Host-specific system configs
│   ├── modules/            # Reusable Nix modules
│   └── lib/                # Helper functions
├── nvim/                   # Neovim configuration (LazyVim-based)
│   ├── lua/                # Lua plugins and config
│   └── stylua.toml         # Lua formatter config
└── sketchybar/             # macOS status bar config
```

## Build Commands

### From nix/ directory:

```bash
# Build macOS configuration
make darwin

# Build NixOS kirby configuration
make nixos

# Build NixOS WSL configuration
make wsl

# Build Ubuntu WSL configuration
make ubuntu

# Update flake inputs
make update

# Clean old generations
make clean
```

### Manual rebuild commands:

```bash
# macOS
darwin-rebuild switch --flake .#Sterling-MBP

# NixOS
sudo nixos-rebuild switch --flake .#kirby

# NixOS WSL
sudo nixos-rebuild switch --flake .#wsl

# Ubuntu WSL
home-manager switch --flake .#sirwayne
```

### Format and Lint Commands

```bash
# Format Nix files (nixfmt-tree)
make format    # or: make fmt
nix fmt

# Lint Nix files (statix)
make lint
statix check .

# Run pre-commit hooks
pre-commit install
pre-commit run --all-files

# Run treefmt for formatting
treefmt
```

### Testing

No formal test framework exists. Validate changes by building:

```bash
# Dry-run to check for errors (NixOS)
sudo nixos-rebuild dry-run --flake .#kirby

# Dry-run for Darwin
darwin-rebuild dry-run --flake .#Sterling-MBP
```

## Code Style Guidelines

### Nix Files

- **Indentation**: 2 spaces (enforced by `.editorconfig`)
- **Formatting**: Use `nix fmt` or `treefmt` before committing
- **Line width**: No strict limit, but keep lines reasonable
- **Attribute ordering**: Group related attributes together

### Nix Expression Style

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

  programs = {
    # Enable and configure together
    git = {
      enable = true;
      userName = "Your Name";
      userEmail = "email@example.com";
    };
  };

  # Use enable = true pattern consistently
  services.foo.enable = true;
}
```

### Naming Conventions

- **Files**: `kebab-case.nix` (e.g., `neovim.nix`, `hyprland.nix`)
- **Attributes**: `camelCase` or `kebab-case` consistently within a file
- **Modules**: Descriptive names, singular form (e.g., `boot.nix`, not `boots.nix`)
- **Hosts**: Hostnames (e.g., `kirby`, `Sterling-MBP`, `wsl`)

### Import Organization

Follow this import order in `default.nix` files:

1. Import shared modules (top-level `./module.nix`)
2. Import platform modules (`./darwin/`, `./nixos/`)
3. Import host modules (`./nixos/kirby/`)

Example from `home/default.nix`:

```nix
{
  imports = [
    # Shared (applied to all systems)
    ./zsh.nix
    ./neovim.nix
    ./git.nix
    # Platform-specific
    ./darwin
    ./nixos
  ];
}
```

### Attribute Sets

Use trailing commas for better diffs:

```nix
{
  option1 = true;
  option2 = {
    key = "value";
  };
}
```

### Package Definitions

Group packages in `packages.nix` by category with headers:

```nix
# Nix & Editor Tools
packages = with pkgs; [
  # formatter
  nixfmt-rfc-style
  # linter
  statix
]

# Development Tools
++ with pkgs; [
  git
  gh
]
```

### Error Handling

- Use `lib.mkIf` for conditional options instead of `if then else`
- Use `lib.mkMerge` for merging attribute sets
- Use `lib.mkDefault` for sensible defaults

```nix
# Good: Conditional enable
services.foo.enable = pkgs.stdenv.hostPlatform.isLinux;

# Good: Merge configurations
programs.zsh.initExtra = lib.mkMerge [
  (lib.mkIf cfg.enablePlugin1 ''
    # plugin1 config
  '')
  (lib.mkIf cfg.enablePlugin2 ''
    # plugin2 config
  '')
];
```

### Neovim Configuration (nvim/)

- **Language**: Lua
- **Framework**: LazyVim (see `lazyvim.json`)
- **Formatter**: stylua (configured in `stylua.toml`)
  - 2-space indentation
  - 120 column width

Run Lua formatter:
```bash
stylua lua/
```

## General Principles

1. **Test before committing**: Always run `make lint` and `make format`
2. **Modularize**: Create separate files for distinct concerns
3. **Document host-specifics**: Add comments for non-obvious configurations
4. **Use flakes**: All new configurations should use the flake-based setup
5. **Follow the structure**: Place files in appropriate directories per the project structure

## Pre-commit Setup

Install pre-commit hooks to automatically lint and format:

```bash
cd nix
pre-commit install
```

This runs `statix check`, `treefmt`, and file validation on commit.

## Useful Nix Commands

```bash
# Evaluate and show the resulting config
nix eval .#nixosConfigurations.kirby.config.system.build.toplevel

# Show differences
nix diff ./result /run/current-system

# Search for packages
nix search nixpkgs package-name

# Clean up
nix-store --gc
```
