# nix/hosts/nixos/wsl/

## Responsibility
Host-specific NixOS module for a **WSL (Windows Subsystem for Linux)** environment. **This host is orphaned — it is NOT currently exported from `nix/flake.nix`**. It exists in the tree from a prior iteration and is retained for reference only. Do not add dependencies on it without confirming with the maintainer.

## Design
- **Standalone module**: Contains only `default.nix` — a single file defining the entire WSL configuration.
- **Imports**: Only `../../../modules/common` (nix-core, common apps). Does **not** import `../../../modules/nixos` — unlike the `kirby` host, it has no desktop, Hyprland, flatpak, or other NixOS-specific modules.
- **WSL-specific options**: Uses the `wsl` NixOS module (`wsl.enable = true`) to configure WSL integration: automount at `/mnt`, `defaultUser`, `startMenuLaunchers`.
- **Shell**: Sets `users.defaultUserShell = pkgs.zsh`.
- **Nix settings**: `auto-optimise-store`, `eval-cores = 0`, automatic GC (daily, >7d), automatic optimisation.
- **nix-ld**: Configures `programs.nix-ld.libraries` for running unfree binaries (stdenv.cc.cc, zlib, openssl).
- **State version**: `"24.05"` — older than the active `kirby` host (25.05), suggesting it was created during an earlier NixOS release.

## Key Configuration Options
| Option | Value / Effect |
|--------|---------------|
| `wsl.enable` | `true` |
| `wsl.wslConf.automount.root` | `"/mnt"` |
| `wsl.defaultUser` | `"sirwayne"` |
| `wsl.startMenuLaunchers` | `true` |
| `users.defaultUserShell` | `pkgs.zsh` |
| `environment.systemPackages` | `[ wslu, socat ]` |
| `programs.nix-ld.libraries` | `[ stdenv.cc.cc, zlib, openssl ]` |
| `nix.gc.automatic` | `true` |
| `nix.gc.options` | `"--delete-older-than 7d"` |
| `nix.optimise.automatic` | `true` |
| `system.stateVersion` | `"24.05"` |

## Orphan Status
- **Not wired in any flake output**: No `nixosConfigurations` entry in `flake.nix` references `./hosts/nixos/wsl`. There are also orphaned `home/nixos/wsl/` and `home/ubuntu/` directories that share this status.
- **No rebuild path**: `make nixos` will never evaluate this configuration. To reactivate it, a new `nixosConfigurations` entry would need to be added to `flake.nix`.
- **Retained for reference** as a template for future WSL bringup or comparison.

## Integration
- **Imports**: `../../../modules/common` only.
- **Consumer**: None currently — no flake output references this module.
- **Related orphaned directories**: `nix/home/nixos/wsl/`, `nix/home/ubuntu/` — also not wired into the flake.
