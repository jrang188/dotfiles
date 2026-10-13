# nix/home/nixos/kirby/

## Responsibility

Host-specific Home Manager configuration for the `kirby` NixOS machine (x86_64-linux). Configures the complete desktop environment: Hyprland compositor (lua config, built-in `dwindle` layout), ashell status bar, Rofi launcher, Sway notification center, KDE Plasma autostart (fallback), Tokyo Night dark theme, Zen Browser (beta), development IDEs, communication apps, media, and system utilities.

## Design

- **Module composition via `default.nix`**: The entry point imports 9 submodules and overrides `programs.ghostty.package = pkgs.ghostty` (source-built, unlike Darwin's `ghostty-bin`).
- **Conditional configuration via `lib.mkIf`**: `theme.nix` gates GTK/Qt theme, XDG portal config, session variables, and theme packages on `config.wayland.windowManager.hyprland.enable`. `kde.nix` gates the 1Password autostart entry on Hyprland being **disabled** (i.e., when running KDE Plasma instead).
- **Hyprland as primary WM**: `hyprland.nix` (941 lines) is the largest module — full compositor config using the **lua config schema** (`configType = "lua"`, migrated off hyprlang 2026-08-30; hyprlang is deprecated as of Hyprland 0.55, slated for removal in 0.57/0.58). Top-level `settings` keys map 1:1 to `hl.<key>(...)` calls (`config`, `monitor`, `curve`, `animation`, `bind`, `on`); anything that must render as Lua *code* (dispatcher calls, the `hl.on("hyprland.start", ...)` autostart closure) is wrapped in `lib.generators.mkLuaInline`. Tiling uses Hyprland's **built-in `dwindle` layout** (`general.layout = "dwindle"` plus a `dwindle.preserve_split` block) — the **hy3 plugin was removed 2026-08-29** after repeated ABI breakage across nixpkgs Hyprland bumps (each hy3 release is pinned to one exact Hyprland patch version). Custom keybindings (Alt-based navigation inspired by Aerospace), multimonitor support, multimedia keys, hyprlock (lock screen), hypridle (idle management), hyprpaper (wallpaper), and hyprsunset (blue light filter).
- **`systemd.enable = false` is deliberate**: it must stay false while the session launches through uwsm (`programs.hyprland.withUWSM = true` in `nix/modules/nixos/hyprland.nix`). Home-manager's default (`true`) injects an `exec-once` that `systemctl --user stop`s `hyprland-session.target`; under uwsm that stop propagates back into the compositor's own unit and SIGTERMs Hyprland ~1s after a clean start (exit 0, `OnSuccess=`, no crash) — the appearance of an SDDM login loop with no errors. Upstream: hyprwm/Hyprland#15688. Trade-off: the plain (non-uwsm) `hyprland.desktop` session no longer brings up `graphical-session.target`, so hypridle/hyprpaper/hyprsunset/swaync won't autostart there — log in via "Hyprland (uwsm-managed)".
- **Status bar replacement**: `ashell.nix` configures `programs.ashell` (replacing the older hyprpanel) with systemd integration scoped to `graphical-session.target` — not `hyprland-session.target`, which is only started by `wayland.windowManager.hyprland.systemd.enable` (false here); under uwsm `graphical-session.target` is what actually comes up. Layout follows a left/center/right module pattern with workspaces, tray, window title, system info, media player, clock, and settings indicators. Swatches are Tokyo Night (`primary #7aa2f7`, `success #9ece6a`, backgrounds `#1a1b26`/`#24273a`/`#414868`).
- **Application categories**: `apps.nix` groups packages by purpose — IDEs (Cursor, VS Code, Zed, IntelliJ IDEA), terminals (Kitty, Warp), productivity (Obsidian, Notion, Ollama, Todoist, HTTPie, Xournal++), communication (Discord, Webcord, Vesktop, Zoom), media (Spotify), browsers (Edge), containers (Podman Desktop), gaming (Prism Launcher), and system tools (Blueman). `packages.nix` holds Wayland/system utilities (wl-clipboard, chntpw, clang, tailscale-systray).
- **External flake dependencies**: `zen-browser.nix` imports `zen-browser.homeModules.beta` from `github:0xc000022070/zen-browser-flake`.
- **Rofi with Tokyo Night theme**: `rofi.nix` uses a local `tokyonight.rasi` theme file, Nerd Font display characters, vim-style keybindings, and plugins for calc and emoji modes.

## Flow

1. `flake.nix` → `mkSystem` for host `kirby` → `homeImports = [ ./home ./home/nixos/kirby ]` with `extraArgs` passing `zen-browser` and `llm-agents` inputs. The `hy3` input has been removed entirely from the flake.
2. Shared `./home/default.nix` runs first (shell, editor, git, packages, AI tools).
3. `nix/home/nixos/kirby/default.nix` imports all submodules and sets the Ghostty package.
4. Each submodule sets host-specific options. Hyprland's `settings` attrset is rendered through the lua-config schema via `lib.generators.mkLuaInline`; tiling is delegated to the built-in `dwindle` layout (no plugin).
5. Theme configuration (`theme.nix`) is conditionally applied based on whether Hyprland is enabled.
6. KDE autostart (`kde.nix`) is conditionally applied when Hyprland is **not** enabled, providing fallback desktop integration.

## Integration

- **Flake wiring**: `nix/flake.nix` lines 187–196 — `homeImports = [ ./home ./home/nixos/kirby ]`; `extraArgs` passes `zen-browser` and `llm-agents`.
- **Shared module**: `../../../modules/home/gui.nix` — base Ghostty config overridden here to use `pkgs.ghostty`.
- **External flakes**: `zen-browser` (github:0xc000022070/zen-browser-flake) and `llm-agents` (github:numtide/llm-agents.nix). Hyprland is consumed from nixpkgs, not a direct upstream flake. The `hy3` input was removed 2026-08-29.
- **System-level config**: Paired with `nix/hosts/nixos/kirby/` (NixOS system modules for the same host). `nix/modules/nixos/hyprland.nix` sets `programs.hyprland.withUWSM = true`, which is why `systemd.enable = false` here is load-bearing.
- **Auto-upgrade**: `kirby` has `system.autoUpgrade` enabled at system level, triggering rebuild from `/home/sirwayne/dotfiles/nix#kirby` every Monday/Thursday at 04:00.
