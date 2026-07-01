# nix/home/

## Responsibility

Shared Home Manager configuration root — the base user environment applied to every host (both Darwin and NixOS). Provides common shell, editor, file manager, git, prompt, and package configuration that is platform-agnostic. Acts as the entry point for all Home Manager module imports for both `Sterling-MBP` and `kirby`.

## Design

- **Entry-point module pattern**: `default.nix` is the first Home Manager import for every host (wired in `flake.nix` via `homeImports = [ ./home ... ]`). It establishes a shared baseline before host-specific modules are layered on via `mkMerge` semantics.
- **Flat module composition**: Each concern (zsh, neovim, git, tmux, etc.) lives in its own top-level `.nix` file, imported explicitly by `default.nix`. No subdirectory nesting except `./ai`.
- **Platform-conditional home directory**: Uses `pkgs.stdenv.hostPlatform.system` to determine `homeDirectory` — Darwin gets `/Users/${username}`, Linux gets `/home/${username}`.
- **Helper injection via `extraSpecialArgs`**: Receives `username`, `pkgs`, `inputs` (and `pkgs-stable`) from `flake.nix`'s `mkSpecialArgs` / `mkHomeManagerConfig`. The `packages.nix` module depends on `inputs` for the `llm-agents` flake reference.
- **Home Manager state version pinned**: `home.stateVersion = "24.11"` — must only be bumped when breaking changes are adopted.

## Flow

1. `flake.nix` calls `mkHomeManagerConfig` with `homeImports = [ ./home ./home/<platform> ]`.
2. `mkHomeManagerConfig` passes `extraSpecialArgs` (username, pkgs, inputs, pkgs-stable) down to the Home Manager user config.
3. `nix/home/default.nix` is evaluated first — it imports submodules: `zsh.nix`, `neovim.nix`, `yazi.nix`, `git.nix`, `tmux.nix`, `oh-my-posh.nix`, `packages.nix`, and `./ai`.
4. Each submodule sets specific `programs.<name>` options, which are merged with host-specific overrides (e.g., `programs.zsh.oh-my-zsh.plugins` gets `"macos"` appended by `nix/home/darwin/default.nix`).
5. The resulting merged attribute set becomes the single Home Manager configuration for the user.

## Integration

- **Flake entry point**: `nix/flake.nix` lines 182–186 (Darwin) and 197–199 (NixOS) wire `./home` as the first element of `homeImports`.
- **Consumed by**: `nix/home/darwin/` (adds Darwin-specific overlays), `nix/home/nixos/kirby/` (adds NixOS- and host-specific overlays). Also consumed by oprhaned configs `nix/home/nixos/wsl/` and `nix/home/ubuntu/` (not wired into flake.nix).
- **External dependency**: `inputs.llm-agents.packages.${system}.opencode` is injected into `home.packages` via `packages.nix`.
- **Shared module dependency**: `nix/modules/home/gui.nix` provides a base `programs.ghostty` config that Darwin and NixOS hosts may import and override.
- **Tmux integration**: `tmux.nix` configures `programs.tmux` with vi mode, 1-based base index, mouse, focus events, and the `vim-tmux-navigator`, `yank`, and `tokyo-night-tmux` tmux plugins. `zsh.nix` enables the `"tmux"` oh-my-zsh completion plugin for shell-level tmux integration.
