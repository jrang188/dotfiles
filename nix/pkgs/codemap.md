# nix/pkgs/

## Responsibility

Custom Nix package derivations that are not (or not yet) available in nixpkgs. These packages can be imported into the wider config via `pkgs.callPackage` and are available to both Darwin and NixOS hosts through the flake's nixpkgs instances.

## Design

- **Standard `callPackage` pattern**: Each `.nix` file defines a function `{ lib, stdenv, fetchFromGitHub, ... }` that returns a derivation via `stdenv.mkDerivation`. Consumers must call `pkgs.callPackage ./<file>.nix { }` explicitly to wire up the arguments — nothing here is auto-discovered.
- **Self-contained derivations**: Each file captures its own source fetching, dependency resolution, build phases, and install phases. No shared overlay or package set wrapper — packages are consumed directly.

## Files

| File | Package | Description |
|---|---|---|
| `unocss-language-server.nix` | `unocss-language-server` v0.1.8 | Language server for UnoCSS. Fetches from `github:xna00/unocss-language-server`, resolves pnpm dependencies via `fetchPnpmDeps` (`pnpm_10`, `fetcherVersion = 3`), builds with `pnpm build`, and installs the compiled `bin/index.js` as `$out/bin/unocss-language-server`. |

## Integration

- **Consumer**: `unocss-language-server` is bound via `pkgs.callPackage ../pkgs/unocss-language-server.nix { }` in `nix/home/neovim.nix` and exposed to LazyVim; any other Nix expression with access to `pkgs` could likewise `callPackage` it and use it in `home.packages` or `environment.systemPackages`.
- **Not a flake output**: These derivations are not directly exposed in the flake's `outputs`; they are resolved transitively through the `pkgs` passed to modules.
- **Not an overlay**: Unlike `nixpkgs` overlays, these packages are standalone files and do not override or patch existing nixpkgs packages.
