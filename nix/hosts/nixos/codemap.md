# nix/hosts/nixos/

## Responsibility
Namespace directory for NixOS host configurations. Contains a single subdirectory, `kirby/` (active, x86_64-linux). There is no `default.nix` at this level — host configs are referenced directly by path from the flake.

## Design
- **Folder-as-namespace**: No aggregate module file; `nixos/` exists to separate NixOS host configs from Darwin configs in the repository layout.
- **Active host**: `kirby/` — the only NixOS host wired into `nix/flake.nix` via `mkSystem`. Full desktop configuration with KDE Plasma 6, Hyprland, secure boot, and encrypted DNS. The former `wsl/` host config has been removed from the tree.
- **Import hierarchy pattern**: Each host module follows the convention of importing `../../../modules/common`, `../../../modules/nixos`, then host-specific files.

## Flow
1. `nix/flake.nix` calls `mkSystem { hostname = "kirby-machine"; system = "x86_64-linux"; modules = [ ./hosts/nixos/kirby ]; ... }`.
2. `mkSystem` assembles the final `nixosSystem` by merging: host module → `inputs.lanzaboote.nixosModules.lanzaboote` (passed per-host from `flake.nix`, not injected by the helper) → `home-manager.nixosModules.home-manager` + Home Manager config + any extra flake inputs (zen-browser, llm-agents). There is no Determinate Nix module — the daemon binary comes from Lix via the shared `modules/common/nix-daemon.nix`.
3. The host module imports shared platform modules and its own specialized submodules.
4. `make nixos` or `nixos-rebuild switch --flake .#kirby` materializes the final configuration.

## Integration
- **Consumer**: `nix/flake.nix` via `mkSystem` — references `./hosts/nixos/kirby` as the host module.
- **Provider to**: `kirby/default.nix` imports `../../../modules/common` and `../../../modules/nixos`.
- **Related flake inputs**: `nixpkgs` (nixos-unstable), `nixpkgs-stable-nixos`, `lanzaboote` (secure boot), `home-manager`, `zen-browser`, `llm-agents`.
