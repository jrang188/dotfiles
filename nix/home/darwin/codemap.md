# nix/home/darwin/

## Responsibility

Darwin-specific Home Manager overlay for macOS host `Sterling-MBP`. Sets platform-specific packages (GUI apps, audio tools, the `jankyborders` window-border helper), overrides the Ghostty terminal package to use the binary distribution, manages the AeroSpace tiling window manager through the `programs.aerospace` module, manages the sketchybar status bar through the `programs.sketchybar` module, appends the `macos` Oh My Zsh plugin, and imports the shared `modules/home/gui.nix` for base Ghostty config.

## Design

- **Platform overlay pattern**: This module is added as a second `homeImports` element for Darwin only (`nix/flake.nix` line 174), merging on top of the shared `./home` baseline. All options here either extend or override the shared config.
- **Host-specific package override**: `programs.ghostty.package = pkgs.ghostty-bin` — uses the pre-built binary rather than building from source (NixOS counterpart uses `pkgs.ghostty`).
- **macOS-specific additions**:
  - `programs.zsh.oh-my-zsh.plugins` gets `"macos"` appended (provides `man`, `pman`, `osx` utility functions).
  - `home.packages` includes `ghostty-bin`, `syncthing-macos` (Syncthing GUI), `switchaudio-osx`, `nowplaying-cli` (audio device switching and media info), and `jankyborders` (`borders`, the window border AeroSpace launches at startup — from nixpkgs, not Homebrew). Mobile-dev deps (`flutter`, `cocoapods`, `android-tools`) and `scrcpy` are present but commented out.
  - `programs.neovim.extraPackages` adds `pngpaste` (paste images from clipboard into Neovim).
- **External module import**: `../../modules/home/gui.nix` provides the shared Ghostty base config (`JetBrainsMono Nerd Font Mono`, `TokyoNight` theme, 88% opacity, blur, Zsh integration).
- **AeroSpace is fully Nix-managed** (`./aerospace.nix`, HM `programs.aerospace`): a single `workspaces` list derives `persistent-workspaces`, the `alt-<key>` focus bindings, the `alt-shift-<key>` move bindings and `workspace-to-monitor-force-assignment`; an `appRules` map of bundle-ids → workspace derives the 17 `on-window-detected` rules. `launchd.enable = true` owns autostart (the module asserts on `start-at-login`/`after-login-command` and rewrites both), and the rendered `settings` are semantically identical to the previous hand-written `aerospace.toml`. `exec.env-vars.PATH` is set explicitly because AeroSpace derives its exec environment from launchd's PATH plus a hardcoded Homebrew prefix — never the Nix profile — which is what broke the `sketchybar --trigger` callbacks. `after-startup-command` launches `borders`, which resolves to `pkgs.jankyborders` from `./packages.nix` (the `felixkratz/formulae` Homebrew tap was dropped); sketchybar is deliberately *not* started here, since its own Home Manager launchd agent owns it.
- **sketchybar is fully Nix-managed** (`./sketchybar.nix`, HM `programs.sketchybar`): `configType = "lua"` with `pkgs.sbarlua` supplies the SbarLua C module and pins the Lua interpreter through `passthru.luaModule`, and the module writes a `gui/$UID` launchd agent. The generated wrapper is the single source of truth for the bar's `PATH` — only `extraPackages` plus the system/Homebrew dirs — so every external CLI the Lua config shells out to must be listed there. The Lua tree itself is linked by `xdg.configFile."sketchybar"` as an out-of-store symlink, because `helpers/init.lua` runs `make` into the repo at startup.

## Flow

1. `flake.nix` → `mkDarwin` → sets `homeImports = [ ./home ./home/darwin ... ]`.
2. Shared `./home/default.nix` runs first, establishing common programs and packages.
3. `nix/home/darwin/default.nix` imports `../../modules/home/gui.nix`, `./aerospace.nix`, `./packages.nix`, `./gui.nix`, and `./sketchybar.nix`.
4. `gui.nix` overrides `programs.ghostty.package` to `ghostty-bin`.
5. `packages.nix` adds Darwin-only packages and neovim extras.
6. `aerospace.nix` enables `programs.aerospace` (config → `~/.aerospace.toml`, launchd agent → autostart).
7. `sketchybar.nix` enables `programs.sketchybar` (launchd agent + wrapped binary), links `~/dotfiles/sketchybar` to `~/.config/sketchybar`, and creates `~/Library/Logs/sketchybar/`.
8. `default.nix` appends `"macos"` to the shared Oh My Zsh plugin list.

## Integration

- **Flake wiring**: `nix/flake.nix` line 174 — `homeImports` element for `Sterling-MBP` only.
- **Shared dependency**: `../../modules/home/gui.nix` — base Ghostty config provided by `nix/modules/home/`.
- **External module**: `inputs.mac-app-util.homeManagerModules.default` (imported separately in flake.nix) provides macOS app trampolining.
- **Consumed by**: `nix/darwin/home.nix` (if present) or the Darwin system module defined in `nix/hosts/darwin/Sterling-MBP/`.
