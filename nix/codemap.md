# nix/

## Responsibility

Central configuration root for the flake-based Nix system. Owns the entry point (`flake.nix`), build automation (`Makefile`), linter/formatter configuration (`.editorconfig`, `.pre-commit-config.yaml`), and the directory tree consumed by the flake outputs — Home Manager user profiles, host-level system modules, reusable Nix modules, and custom package derivations.

## Design

- **Flake-as-Orchestrator**: `flake.nix` is the single entry point. All meaningful outputs (system configurations, home-manager configs, formatter definitions) are declared in its `outputs` block. The flake does not call out to external build scripts; `make` targets are convenience wrappers around `nh` (Nothing Hermetic) commands and `nix flake update`.
- **Helper-function abstraction layer (`mkSpecialArgs`, `mkStablePkgs`, `mkHomeManagerConfig`, `mkSystem`, `mkDarwin`)** reduces duplication across the two active hosts. These functions inject common `specialArgs`/`extraSpecialArgs` (username, hostname, inputs, `pkgs-stable`) and wire up mandatory infrastructure modules (home-manager, determinate Nix, mac-app-util, nix-homebrew, lanzaboote) so host-level configs only need to specify their own imports.
- **Platform-separated nixpkgs inputs**: Four nixpkgs channels — `nixpkgs` (nixos-unstable, heavy with NixOS tests), `nixpkgs-darwin` (nixpkgs-unstable, lighter), `nixpkgs-stable-nixos` (nixos-26.05), `nixpkgs-stable-darwin` (nixpkgs-26.05-darwin). The `getStableNixpkgs` function dispatches to the correct stable channel based on `system`.
- **Module Composition pattern**: Each host output assembles a module list by concatenating its own host module with shared infrastructure modules. The `mkHomeManagerConfig` call is injected as one of those modules, making Home Manager a first-class participant in the system module stack.
- **External flake pinning for stability**: `mac-app-util` is pinned independently (does not follow nixpkgs) to avoid an SBCL build regression. `hyprland` and `hy3` are pinned together with ABI-locked follows. `lanzaboote` is pinned to v1.1.0.
- **Determinate Nix on Darwin**: `nix.enable = false` in the Darwin module stack because Determinate Nix manages the Nix daemon instead.

## Flow

1. **User runs `make darwin` (or `make nixos`)** → Makefile delegates to `nh darwin switch . -H Sterling-MBP` (or `nh os switch . -H kirby`).
2. **`nh` evaluates the flake** → loads `flake.nix`, resolves all inputs (nixpkgs, nixpkgs-darwin, darwin, home-manager, etc.), and invokes the matching output.
3. **For `Sterling-MBP` (Darwin)** → `mkDarwin` is called with `hostname = "Sterling-MBP"`, module list `[ ./hosts/darwin/Sterling-MBP ]`, and home imports `[ ./home ./home/darwin mac-app-util.homeManagerModules ]`.
   - `mkDarwin` injects: `{ nix.enable = false }` + mac-app-util + home-manager-darwin + `mkHomeManagerConfig(...)` + nix-homebrew.
   - `mkHomeManagerConfig` creates the `home-manager` submodule with `extraSpecialArgs` built by `mkSpecialArgs`, which includes `pkgs-stable` (from nixpkgs-stable-darwin).
4. **For `kirby` (NixOS)** → `mkSystem` is called with `hostname = "kirby-machine"`, `system = "x86_64-linux"`, modules `[ ./hosts/nixos/kirby lanzaboote.nixosModules.lanzaboote ]`, home imports `[ ./home ./home/nixos/kirby ]`, and extra args carrying `zen-browser`, `llm-agents`, `hyprland`, `hy3`.
   - `mkSystem` injects: determinate Nix module + home-manager + `mkHomeManagerConfig(...)`.
   - `pkgs-stable` comes from nixpkgs-stable-nixos.
5. **Home Manager evaluates** → `extraSpecialArgs` make `username`, `hostname`, `inputs`, and `pkgs-stable` available to every Home Manager module. The user's `home.nix` and platform-specific configs are imported.
6. **Formatter outputs** → `nix fmt` invokes `nixfmt-tree` from the appropriate nixpkgs for each platform.

## Integration

- **Makefile** (consumer): Wraps `nh darwin switch`, `nh os switch`, `nh clean all`, `nix flake update`, `statix`, `nix fmt`. Run from the `nix/` directory.
- **`.editorconfig`**: Enforces 2-space indentation for `*.nix`, LF line endings, UTF-8, trailing-newline, and trim-trailing-whitespace.
- **`.pre-commit-config.yaml`**: Local hooks run `treefmt` (nixfmt-tree) and `statix check .` on Nix files; generic hooks from `pre-commit-hooks` v6.0.0 handle trailing-whitespace, end-of-file-fixer, check-yaml, check-json. Activated by `pre-commit install` in `nix/`.
- **`home/`** (dependency): Home Manager module tree consumed by `mkHomeManagerConfig`. Contains shared profile (`default.nix`, `packages.nix`, `zsh.nix`, `git.nix`, `neovim.nix`, `oh-my-posh.nix`, `yazi.nix`, `ai/`) and platform-specific directories (`darwin/`, `nixos/`).
- **`hosts/`** (dependency): Host-level NixOS (`hosts/nixos/kirby/`) and Darwin (`hosts/darwin/Sterling-MBP/`) system modules, referenced directly in the host output declarations.
- **`modules/`** (dependency): Reusable Nix modules organized by scope (`common/`, `darwin/`, `home/`, `nixos/`).
- **`pkgs/`** (dependency): Custom package derivations available via `pkgs.callPackage`.
- **`lib/`** (currently empty): Intended for shared Nix helper functions.
- **`flake.lock`**: Pinned dependency manifest, updated via `nix flake update`.
- **External inputs**: `nixpkgs`, `nixpkgs-darwin`, `nixpkgs-stable-nixos`, `nixpkgs-stable-darwin`, `determinate`, `darwin`, `mac-app-util`, `nix-homebrew`, `home-manager`, `home-manager-darwin`, `zen-browser`, `lanzaboote`, `hyprland`, `hy3`, `llm-agents`.
