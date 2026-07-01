# nix/home/darwin/

## Responsibility

Darwin-specific Home Manager overlay for macOS host `Sterling-MBP`. Sets platform-specific packages (GUI apps, audio tools), overrides the Ghostty terminal package to use the binary distribution, appends the `macos` Oh My Zsh plugin, and imports the shared `modules/home/gui.nix` for base Ghostty config.

## Design

- **Platform overlay pattern**: This module is added as a second `homeImports` element for Darwin only (`nix/flake.nix` line 184), merging on top of the shared `./home` baseline. All options here either extend or override the shared config.
- **Host-specific package override**: `programs.ghostty.package = pkgs.ghostty-bin` — uses the pre-built binary rather than building from source (NixOS counterpart uses `pkgs.ghostty`).
- **macOS-specific additions**:
  - `programs.zsh.oh-my-zsh.plugins` gets `"macos"` appended (provides `man`, `pman`, `osx` utility functions).
  - `home.packages` includes `ghostty-bin`, `switchaudio-osx`, `nowplaying-cli` (audio device switching and media info).
  - `programs.neovim.extraPackages` adds `pngpaste` (paste images from clipboard into Neovim).
- **External module import**: `../../modules/home/gui.nix` provides the shared Ghostty base config (`JetBrainsMono Nerd Font Mono`, `TokyoNight` theme, 88% opacity, blur, Zsh integration).

## Flow

1. `flake.nix` → `mkDarwin` → sets `homeImports = [ ./home ./home/darwin ... ]`.
2. Shared `./home/default.nix` runs first, establishing common programs and packages.
3. `nix/home/darwin/default.nix` imports `../../modules/home/gui.nix`, `./packages.nix`, and `./gui.nix`.
4. `gui.nix` overrides `programs.ghostty.package` to `ghostty-bin`.
5. `packages.nix` adds Darwin-only packages and neovim extras.
6. `default.nix` appends `"macos"` to the shared Oh My Zsh plugin list.

## Integration

- **Flake wiring**: `nix/flake.nix` line 184 — `homeImports` element for `Sterling-MBP` only.
- **Shared dependency**: `../../modules/home/gui.nix` — base Ghostty config provided by `nix/modules/home/`.
- **External module**: `inputs.mac-app-util.homeManagerModules.default` (imported separately in flake.nix) provides macOS app trampolining.
- **Consumed by**: `nix/darwin/home.nix` (if present) or the Darwin system module defined in `nix/hosts/darwin/Sterling-MBP/`.
