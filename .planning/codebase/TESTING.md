---
title: Testing & Validation
last_mapped: 2026-05-26
---

# Testing & Validation

## Testing Philosophy

This is a dotfiles/system-configuration repository. There is no application test suite. Validation is entirely build-time: if `nix build` / `darwin-rebuild` / `nixos-rebuild` succeeds, the configuration is considered correct.

---

## Validation Methods

### 1. Dry Run (Primary pre-commit check)

```bash
# macOS — evaluate without switching
darwin-rebuild dry-run --flake .#Sterling-MBP

# NixOS — evaluate without switching
sudo nixos-rebuild dry-run --flake .#kirby
```

This catches:
- Nix evaluation errors (syntax, type errors, undefined references)
- Module option type mismatches
- Missing inputs / broken derivation references

### 2. Full Build + Switch

```bash
# macOS
make darwin     # nh darwin switch . -H Sterling-MBP

# NixOS
make nixos      # nh os switch . -H kirby
```

Runs a full build and activates the new generation.

### 3. Lint (statix)

```bash
make lint       # statix check .
```

Checks for anti-patterns:
- Redundant `let` bindings
- Unnecessary `with` scopes
- `rec` sets that don't need recursion
- Deprecated Nix idioms

### 4. Format Check (nixfmt / treefmt)

```bash
make format     # nix fmt  (uses nixfmt via flake formatter output)
# or
nix fmt
treefmt         # runs all formatters including nixfmt-tree
```

### 5. Pre-commit Hooks

Installed via `pre-commit install` in `nix/`:

| Hook | What it checks |
|---|---|
| `nixfmt-tree` | All `.nix` files are properly formatted |
| `statix-check` | No Nix anti-patterns |
| `trailing-whitespace` | No trailing whitespace in `.nix` files |
| `end-of-file-fixer` | Files end with newline |
| `check-yaml` | YAML files parse correctly |
| `check-json` | JSON files parse correctly |

Run manually: `pre-commit run --all-files`

---

## What Is Not Tested

| Gap | Impact |
|---|---|
| No automated Nix evaluation CI | Breaking changes only caught when manually building |
| No flake check (`nix flake check`) in CI | Module evaluation not validated on push |
| No NixOS VM tests | Integration behavior untested |
| No MCP server availability checks | MCP servers may fail silently at runtime |
| WSL / Ubuntu configs not in flake outputs | These configurations can silently rot |
| Homebrew cask validity | Casks can become unavailable without error until next `darwin-rebuild` |

---

## Flake Evaluation

```bash
# Show the resulting system derivation (deep evaluation)
nix eval .#nixosConfigurations.kirby.config.system.build.toplevel

# Show diff between current and new generation
nix diff ./result /run/current-system

# Check all flake outputs are evaluatable
nix flake check
```

---

## Garbage Collection / Rollback

```bash
make clean      # nh clean all (removes old generations)

# Manual rollback
darwin-rebuild --rollback
nixos-rebuild --rollback
```

---

## No Formal Test Framework

There is no:
- `nixosTests` module usage
- NixOS test VMs (`nixos/tests/`)
- Unit tests for Nix helper functions in `lib/`
- Automated CI pipeline (no `.github/workflows/`, no CI config)
