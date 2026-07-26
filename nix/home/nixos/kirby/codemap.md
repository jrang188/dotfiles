# nix/home/nixos/kirby/

## Responsibility

Host-specific Home Manager configuration for the `kirby` NixOS machine (x86_64-linux). Configures the complete desktop environment: Hyprland compositor (with hy3 tiling plugin), ashell status bar, Rofi launcher, Sway notification center, KDE Plasma autostart (fallback), Tokyo Night dark theme, Zen Browser (beta), development IDEs, communication apps, media, and system utilities.

## Design

- **Module composition via `default.nix`**: The entry point imports 9 submodules and overrides `programs.ghostty.package = pkgs.ghostty` (source-built, unlike Darwin's `ghostty-bin`).
- **Conditional configuration via `lib.mkIf`**: `theme.nix` gates GTK/Qt theme, XDG portal config, session variables, and theme packages on `config.wayland.windowManager.hyprland.enable`. `kde.nix` gates the 1Password autostart entry on Hyprland being **disabled** (i.e., when running KDE Plasma instead).
- **Hyprland as primary WM**: `hyprland.nix` (389 lines) is the largest module — full compositor config with hy3 tiling plugin, custom keybindings (Alt-based navigation inspired by Aerospace), hy3 workspace semantics, multimonitor support, multimedia keys, hyprlock (lock screen), hypridle (idle management), hyprpaper (wallpaper), and hyprsunset (blue light filter).
- **Status bar replacement**: `ashell.nix` configures `programs.ashell` (replacing the older hyprpanel) with systemd integration scoped to `hyprland-session.target`. Layout follows a left/center/right module pattern with workspaces, tray, window title, system info, media player, clock, and settings indicators.
- **Application categories**: `apps.nix` groups packages by purpose — IDEs (Cursor, VS Code, Zed, IntelliJ IDEA), terminals (Kitty, Warp), productivity (Obsidian, Notion, Ollama, Todoist), communication (Discord, Zoom), media (Spotify), browsers (Edge), containers (Podman Desktop), and gaming (Prism Launcher).
- **External flake dependencies**: `zen-browser.nix` imports `zen-browser.homeModules.beta` from `github:0xc000022070/zen-browser-flake`. `hyprland.nix` references `inputs.hy3` for the hy3 plugin.
- **Rofi with Tokyo Night theme**: `rofi.nix` uses a local `tokyonight.rasi` theme file, Nerd Font display characters, vim-style keybindings, and plugins for calc and emoji modes.

## Flow

1. `flake.nix` → `mkSystem` for host `kirby` → `homeImports = [ ./home ./home/nixos/kirby ]` with `extraArgs` passing `zen-browser`, `llm-agents`, and `hy3` inputs.
2. Shared `./home/default.nix` runs first (shell, editor, git, packages, AI tools).
3. `nix/home/nixos/kirby/default.nix` imports all submodules and sets the Ghostty package.
4. Each submodule sets host-specific options. The `hy3` plugin is loaded as a Hyprland plugin (line 223 of `hyprland.nix`, `plugins` list).
5. Theme configuration (`theme.nix`) is conditionally applied based on whether Hyprland is enabled.
6. KDE autostart (`kde.nix`) is conditionally applied when Hyprland is **not** enabled, providing fallback desktop integration.

## Integration

- **Flake wiring**: `nix/flake.nix` lines 190–209 — `homeImports = [ ./home ./home/nixos/kirby ]`.
- **Shared module**: `../../../modules/home/gui.nix` — base Ghostty config overridden here to use `pkgs.ghostty`.
- **External flakes**: `zen-browser` (github:0xc000022070/zen-browser-flake), `hy3` (github:outfoxxed/hy3). Hyprland is consumed from nixpkgs, not a direct upstream flake.
- **System-level config**: Paired with `nix/hosts/nixos/kirby/` (NixOS system modules for the same host).
- **Auto-upgrade**: `kirby` has `system.autoUpgrade` enabled at system level, triggering rebuild from `/home/sirwayne/dotfiles/nix#kirby` every Monday/Thursday at 04:00.
