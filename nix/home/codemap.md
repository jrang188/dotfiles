# nix/home/

## Responsibility

Shared Home Manager configuration root — the base user environment applied to every host (both Darwin and NixOS). Provides common shell, editor, file manager, git, prompt, and package configuration that is platform-agnostic. Acts as the entry point for all Home Manager module imports for both `Sterling-MBP` and `kirby`.

## Design

- **Entry-point module pattern**: `default.nix` is the first Home Manager import for every host (wired in `flake.nix` via `homeImports = [ ./home ... ]`). It establishes a shared baseline before host-specific modules are layered on via `mkMerge` semantics.
- **Flat module composition**: Each concern (zsh, neovim, git, tmux, etc.) lives in its own top-level `.nix` file, imported explicitly by `default.nix` (subdirs `./ai`, plus `./darwin` and `./nixos/<host>` which `flake.nix` imports after this root).
- **Platform-conditional home directory**: Uses `pkgs.stdenv.hostPlatform.system` to determine `homeDirectory` — Darwin gets `/Users/${username}`, Linux gets `/home/${username}`.
- **Helper injection via `extraSpecialArgs`**: Receives `username`, `pkgs`, `inputs` (and `pkgs-stable`) from `flake.nix`'s `mkSpecialArgs` / `mkHomeManagerConfig`. `packages.nix` itself is a plain `{ pkgs, ... }` module with no flake-input dependency; `inputs.llm-agents` is consumed only by the `./ai` subtree.
- **Home Manager state version pinned**: `home.stateVersion = "24.11"` — must only be bumped when breaking changes are adopted.
- **`initContent` carries the imperative shell bits** (`zsh.nix`): prepends `$HOME/.local/bin` to `PATH`, exports `GOPATH=$HOME/go` and appends `/usr/local/go/bin:$GOPATH/bin`, and defines a `brew()` wrapper that fires `sketchybar --trigger brew_update` on `upgrade`/`update`/`outdated`. An `opencode` wrapper that injected an explicit `--port` for the oh-my-opencode-slim tmux multiplexer is present but **commented out** (disabled 2026-08-16), and the earlier `[[ -f ~/.config/op/plugins.sh ]] && source ...` line was removed outright in the same commit — nothing under `~/.config/op/` is sourced now.
- **No vendored package pins**: the `1password-cli` override (`let _1password-cli = pkgs.callPackage ../pkgs/1password-cli.nix`) was dropped 2026-08-29 once nixpkgs shipped 2.39.0; `nix/pkgs/1password-cli.nix` no longer exists. The single exception is a narrow, time-boxed override that lives inside `neovim.nix` itself (not in `nix/pkgs/`), described below.
- **Temporary `debugpy` test-skip override** (`neovim.nix`, added 2026-10-13): a local `let` binding wraps `pkgs.python314Packages.debugpy.overrideAttrs` to append `tests/debugpy/server/test_add_code_to_python_process.py::test_lldb_command` to `disabledTestPaths` on Darwin only. debugpy 1.8.22 added that test, which asserts the generated lldb attach command starts with the bare `lldb` name; nixpkgs' `hardcode-lldb.patch` rewrites it to the store path, so the assertion fails on Darwin. Fixed upstream in [NixOS/nixpkgs#572564](https://github.com/NixOS/nixpkgs/pull/572564) (merged 2026-10-11), but not yet on the `nixpkgs-unstable` branch this flake's `nixpkgs-darwin` tracks — remove the override once that branch contains the fix. `home.packages` references the local `debugpy` binding (DAP/debugging section) instead of `python314Packages.debugpy`.
- **Self-maintenance in `default.nix`**: enables `programs.home-manager`, `programs.nh` (weekly `nh clean` with `--keep-since 4d --keep 3 --optimise`), and `programs.direnv` (`nix-direnv` + zsh integration, set in `packages.nix`).

## Flow

1. `flake.nix` calls `mkHomeManagerConfig` with `homeImports = [ ./home ./home/<platform> ]`.
2. `mkHomeManagerConfig` passes `extraSpecialArgs` (username, pkgs, inputs, pkgs-stable) down to the Home Manager user config.
3. `nix/home/default.nix` is evaluated first — it sets `home.username`/`homeDirectory`/`stateVersion` and imports submodules in this order: `zsh.nix`, `neovim.nix`, `yazi.nix`, `git.nix`, `oh-my-posh.nix`, `packages.nix`, `./ai`, `tmux.nix`.
4. Each submodule sets specific `programs.<name>` options, which are merged with host-specific overrides (e.g., `programs.zsh.oh-my-zsh.plugins` gets `"macos"` appended by `nix/home/darwin/default.nix`).
5. The resulting merged attribute set becomes the single Home Manager configuration for the user.

## Integration

- **Flake entry point**: `nix/flake.nix` lines 172–174 (`homeImports = [ ./home ./home/darwin ]`) and 187–189 (NixOS: `[ ./home ./home/nixos/kirby ]`) wire `./home` as the first element of `homeImports`.
- **Consumed by**: `nix/home/darwin/` (imports `modules/home/gui.nix` plus Darwin `packages.nix`/`gui.nix` and appends `"macos"` to the oh-my-zsh plugin list), `nix/home/nixos/kirby/` (adds NixOS- and host-specific overlays). The former orphaned `nix/home/nixos/wsl/` and `nix/home/ubuntu/` configs have been removed from the tree.
- **External dependency**: `inputs.llm-agents` is used only inside `./ai` (`claude-code.nix` → `.claude-code`, `opencode.nix` → `.opencode2`); `default.nix` itself contributes no flake-input packages.
- **Shared module dependency**: `nix/modules/home/gui.nix` provides a base `programs.ghostty` config that Darwin and NixOS hosts may import and override.
- **Tmux integration**: `tmux.nix` configures `programs.tmux` with `C-Space` prefix, vi mode, 1-based base index, mouse, focus events, `sensibleOnTop`, `historyLimit = 50000`, `disableConfirmationPrompt` (instant `prefix x`/`&`), `tmux-256color` with RGB/undercurl terminal-features for Ghostty (`set -as terminal-features ",xterm-ghostty:RGB:usstyle"`), `set-clipboard on`, `renumber-windows`, cwd-preserving splits (`|`/`-`/`%`/`"`) and new windows (`c`), `Tab` last-window, `prefix r` config reload, prefix `h/j/k/l` pane selection with repeatable `H/J/K/L` resize, vim copy-mode binds (`v`/`C-v`), and the `vim-tmux-navigator` (prefix-free `C-h/j/k/l` nvim↔pane nav), `yank`, and `tokyo-night-tmux` tmux plugins. `zsh.nix` enables the `"tmux"` oh-my-zsh completion plugin for shell-level tmux integration.
- **Package inventory** (`packages.nix`): `home.packages = with pkgs; [ ... ]` grouped under comment banners — Nix & editor tooling, general utilities, language runtimes (nodejs/uv/python3/go/bun/rustup/JDK-21/gradle/maven), dev tools, and DevOps/cloud CLIs. Recent additions: `sops`, `pdftk`, `mkcert`, `argocd`.
