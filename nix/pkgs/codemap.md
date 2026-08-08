# nix/pkgs/

## Responsibility

Custom Nix package derivations that are not (or not yet) available in nixpkgs. These packages can be imported into the wider config via `pkgs.callPackage` and are available to both Darwin and NixOS hosts through the flake's nixpkgs instances.

## Design

- **Standard `callPackage` pattern**: Each `.nix` file defines a function `{ lib, stdenv, fetchFromGitHub, ... }` that returns a derivation via `stdenv.mkDerivation`. The flake's `pkgs` attribute set automatically wires up the required dependencies via `pkgs.callPackage` when included in `home.packages` or system packages.
- **Self-contained derivations**: Each file captures its own source fetching, dependency resolution, build phases, and install phases. No shared overlay or package set wrapper — packages are consumed directly.

## Files

| File | Package | Description |
|---|---|---|
| `unocss-language-server.nix` | `unocss-language-server` v0.1.8 | Language server for UnoCSS. Fetches from `github:xna00/unocss-language-server`, resolves pnpm dependencies via `fetchPnpmDeps` with `pnpm_9`, builds with `pnpm build`, and installs the compiled `bin/index.js` as `$out/bin/unocss-language-server`. |
| `1password-cli.nix` | `1password-cli` v2.38.1 | Vendored copy of nixpkgs' `pkgs/by-name/_1/_1password-cli/package.nix` pinned at 2.38.1 (nixpkgs lags at 2.34.x). Binary fetch from `cache.agilebits.com`, trimmed to the two active platforms (`x86_64-linux` zip, `aarch64-darwin` pkg). Consumed as `pkgs.callPackage ../pkgs/1password-cli.nix { }` in `nix/home/packages.nix`. Drop once nixpkgs ships >= 2.38.1. |

## Integration

- **Consumer**: Any Nix expression with access to `pkgs` can use `pkgs.unocss-language-server` (e.g., in `home.packages` or `environment.systemPackages`). `1password-cli` is consumed via `pkgs.callPackage` in `nix/home/packages.nix:4` (a `let` binding shadowing `pkgs._1password-cli`).
- **Not a flake output**: These derivations are not directly exposed in the flake's `outputs`; they are resolved transitively through the `pkgs` passed to modules.
- **Not an overlay**: Unlike `nixpkgs` overlays, these packages are standalone files and do not override or patch existing nixpkgs packages.
