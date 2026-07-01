# nix/home/nixos/wsl/

## Responsibility

Home Manager configuration for a WSL (Windows Subsystem for Linux) environment. Provides Zsh aliases that bridge WSL tools to their Windows `.exe` counterparts (`ssh.exe`, `ssh-add.exe`), a Neovim wrapper using `socat` + `npiperelay.exe` for Discord IPC forwarding, Git SSH command override, and the `clang` package.

> **⚠️ Orphaned config**: This module is **not exported** from `flake.nix`. It exists in the file tree as a leftover from a prior WSL iteration and is not currently wired into any active host output.

## Design

- **Simple single-file module**: No submodules or `default.nix` aggregation — only `default.nix` with direct option setting.
- **WSL bridge pattern**: Uses `.exe` suffixed Windows executables for SSH operations (`programs.zsh.shellAliases` and `programs.git.settings.core.sshCommand`).
- **Discord IPC relay**: The Neovim wrapper function starts a `socat` listener that forwards `/tmp/discord-ipc-0` to Windows via `npiperelay.exe`, enabling Discord Rich Presence from WSL. The `socat` process is terminated when Neovim exits.
- **Minimal package set**: Only `clang` is added to `home.packages` (C/C++ compiler not bundled with WSL by default).

## Flow

1. If wired, `flake.nix` would include `./home/nixos/wsl` in `homeImports` (currently absent).
2. The module overrides `programs.zsh.shellAliases` so `ssh` and `ssh-add` route to Windows executables.
3. `programs.git.settings.core.sshCommand` overrides Git's SSH transport to use `ssh.exe`.
4. Custom `nvim` and `vim` shell functions wrap the Neovim binary with an optional Discord IPC bridge.

## Integration

- **Flake wiring**: **None** — orphaned. Not referenced in any `homeImports` list in `nix/flake.nix`.
- **Dependencies**: Requires `socat` and `npiperelay.exe` on the Windows side (not managed by this module) for Discord IPC functionality.
- **Related orphaned config**: `nix/home/ubuntu/` — a similar WSL-targeted config with Ubuntu-specific additions.
