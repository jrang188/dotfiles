# nix/modules/home/

## Responsibility
Reusable Home Manager modules — user-scoped, per-user configuration shared across hosts. Currently provides a base GUI terminal configuration (Ghostty) that both Darwin and NixOS hosts import and optionally override.

## Design
- **No aggregator**: The previous `default.nix` aggregator (which re-exported `gui.nix`) was **deleted** — nothing imported it, so it was dead structure. Consumers import `modules/home/gui.nix` directly.
- **Host-overridable defaults**: The Ghostty configuration uses direct assignment (Home Manager's `programs.ghostty.settings`), which can be overridden by host-specific Home Manager configs. For example, NixOS kirby overrides `programs.ghostty.package` to use `pkgs.ghostty` instead of `pkgs.ghostty-bin` (used on Darwin).
- **No custom options defined**: The module sets Home Manager options directly without declaring custom `options` attributes. Override behavior relies on the standard Nix module system merge semantics (later imports win).
- **Single-purpose modules**: Currently contains only one module (`gui.nix`). The directory is designed to accept additional reusable Home Manager modules (e.g. `hyprland.nix`, `rofi.nix`, `ashell.nix`) as shared patterns emerge across hosts.

## Flow
1. A Home Manager host config (e.g. `home/darwin/default.nix` or `home/nixos/kirby/default.nix`) imports `modules/home/gui.nix` directly.
2. `gui.nix` enables `programs.ghostty` with default settings (JetBrainsMono Nerd Font Mono, TokyoNight theme, 88% background opacity, blur enabled, Zsh integration).
3. Host-specific Home Manager configs may then override specific Ghostty settings later in their `imports` list or directly in the config. For example, `home/nixos/kirby/default.nix` overrides `programs.ghostty.package` to use the regular NixOS ghostty package rather than `ghostty-bin`.

## Integration
- **Consumed by**: `home/darwin/default.nix` (imports `../../modules/home/gui.nix`), `home/nixos/kirby/default.nix` (imports `../../../modules/home/gui.nix`).
- **Host overrides**:
  - Darwin: No package override (defaults to `pkgs.ghostty-bin`, installed via the flake's macOS-specific packages).
  - NixOS kirby: Sets `programs.ghostty.package = pkgs.ghostty` to use the nixpkgs variant.
- **Does not depend on**: System-level modules (`common/`, `darwin/`, `nixos/`) — operates independently in the Home Manager evaluation context.

### Module: `gui.nix`
- **File**: `modules/home/gui.nix`
- **Purpose**: Base Ghostty terminal emulator configuration.
- **Key assignments**:
  - `programs.ghostty.enable = true`.
  - `programs.ghostty.settings`: `font-family = "JetBrainsMono Nerd Font Mono"`, `theme = "TokyoNight"`, `background-opacity = 0.88`, `background-blur = true`.
  - `programs.ghostty.enableZshIntegration = true`.
