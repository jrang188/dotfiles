# nix/home/ubuntu/

## Responsibility

Home Manager configuration for an Ubuntu environment (targeting WSL). Extends the WSL bridge pattern from the sibling `nix/home/nixos/wsl/` config with Ubuntu-specific additions: enables the `ubuntu` Oh My Zsh plugin, installs a richer set of common utility packages (`git`, `btop`, `fastfetch`, `ffmpeg`, `wget`, `curl`, `socat`, `clang`), and configures Git's SSH command to use `ssh.exe`.

> **⚠️ Orphaned config**: This module is **not exported** from `flake.nix`. It exists in the file tree as a leftover from a prior WSL/Ubuntu iteration and is not currently wired into any active host output.

## Design

- **Single-file standalone module**: Self-contained `default.nix` with no submodules.
- **WSL bridge pattern** (shared with `nix/home/nixos/wsl/`): Zsh aliases map `ssh` → `ssh.exe` / `ssh-add` → `ssh-add.exe`; Git's `core.sshCommand` is set to `ssh.exe`; Neovim wrapper provides Discord IPC relay via `socat` + `npiperelay.exe`.
- **Ubuntu-specific Oh My Zsh plugin**: `programs.zsh.oh-my-zsh.plugins = [ "ubuntu" ]` adds Ubuntu-specific aliases (e.g., `apt` shortcuts).
- **Richer package set** compared to `nix/home/nixos/wsl/`: Includes `git`, `btop`, `fastfetch`, `ffmpeg`, `wget`, `curl`, `socat`, `clang` — common development utilities for a Linux environment.

## Flow

1. If wired, `flake.nix` would include `./home/ubuntu` in `homeImports` (currently absent).
2. The module enables the `ubuntu` Oh My Zsh plugin for distribution-specific convenience aliases.
3. Zsh aliases and Git `sshCommand` are overridden for WSL interop (same pattern as `nix/home/nixos/wsl/`).
4. `home.packages` installs common CLI tools missing from a minimal Ubuntu WSL image.
5. The `nvim`/`vim` shell function provides the optional Discord IPC bridge via `socat`.

## Integration

- **Flake wiring**: **None** — orphaned. Not referenced in any `homeImports` list in `nix/flake.nix`.
- **Related orphaned config**: `nix/home/nixos/wsl/` — a slimmer WSL config without the Ubuntu plugin or extra packages.
- **Dependencies**: `socat` and `npiperelay.exe` (Windows-side) for Discord IPC bridge; WSL with systemd support for Home Manager operation.
