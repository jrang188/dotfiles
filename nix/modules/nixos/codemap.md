# nix/modules/nixos/

## Responsibility
NixOS-specific system modules for the `kirby` host. Configures containerization (Podman), desktop environment (Hyprland), package management infrastructure (nix-ld), sandboxed application delivery (Flatpak), password management (1Password), device-to-device sharing (LocalSend), the default user shell, and the NixOS timer overlay on the shared Nix daemon config. These modules are only meaningful in a Linux/NixOS context.

## Design
- **Aggregation entry point**: `default.nix` is a **pure import list** of leaf modules plus a small platform timer overlay for the shared `nix-daemon.nix`. The old inline Lix/GC block and `defaultUserShell` were extracted into the common `nix-daemon.nix` and the `user-shell.nix` leaf.
- **Single-purpose leaf modules**: Each `.nix` file focuses on one concern (e.g. `podman.nix` for containerization, `hyprland.nix` for the compositor). This follows the project convention of modularizing by service/tool.
- **No option declarations**: All leaf modules assign existing NixOS option values directly without defining custom options. The module interface is purely the NixOS options namespace.
- **Direct `_` function pattern**: Several modules (`flatpak.nix`, `nix-ld.nix`, `localsend.nix`) use `_: { ... }` — ignoring function arguments entirely — indicating self-contained configs with no external dependencies.
- **Conditional patterns not needed**: Since these modules are exclusive to NixOS, there is no need for `mkIf` platform gating. The shared GC settings come from `modules/common/nix-daemon.nix`; only the timer syntax (`gc.dates`, `optimise.automatic`) is overlaid here.

## Flow
1. `hosts/nixos/kirby/default.nix` imports `../../../modules/nixos`.
2. Nix resolves to `modules/nixos/default.nix`, which:
   - Imports all seven leaf modules.
   - Overlays the NixOS timer syntax on the shared `nix-daemon.nix`: `nix.gc.dates = "Daily"`, `nix.optimise.automatic = true`.
   - The shared `nix-daemon.nix` (via `common`) provides `nix.package` (Lix), `auto-optimise-store`, `gc.automatic`, and `gc.options`.
3. `user-shell.nix` sets `users.defaultUserShell = pkgs.zsh`.
4. Each leaf module evaluates independently and contributes config to the global NixOS configuration merge.

## Integration
- **Depends on**: `pkgs` (in `user-shell.nix`); `pkgs` only (in `hyprland.nix`, which uses `pkgs.hyprland` directly — no flake input needed); `username` (in `1password.nix` for PolKit owner).
- **Consumed by**: `hosts/nixos/kirby/default.nix`.
- **Not consumed by**: The orphaned `hosts/nixos/wsl/default.nix` imports `common` only, not `nixos` — the WSL host config manually duplicates some settings (Nix GC, auto-optimise, default shell) rather than importing this module set.
- **Complemented by**: `modules/common` (separately imported by the host) for cross-platform Nix and font settings, including the shared `nix-daemon.nix`.

### Module: `default.nix`
- **File**: `modules/nixos/default.nix`
- **Purpose**: Pure import aggregator + NixOS timer overlay on the shared `nix-daemon.nix`.
- **Imports**: `flatpak.nix`, `nix-ld.nix`, `1password.nix`, `hyprland.nix`, `podman.nix`, `localsend.nix`, `user-shell.nix`.
- **Inline assignments**:
  - `nix.gc.dates = "Daily"` — NixOS uses `dates` (systemd timer); Darwin uses `interval`.
  - `nix.optimise.automatic = true`.
  - The Lix package, `auto-optimise-store`, `gc.automatic`, and `gc.options` are **not** set here — they come from the shared `modules/common/nix-daemon.nix`.

### Module: `user-shell.nix`
- **File**: `modules/nixos/user-shell.nix`
- **Purpose**: Sets the default user shell to Zsh.
- **Key assignment**: `users.defaultUserShell = pkgs.zsh`.

### Module: `podman.nix`
- **File**: `modules/nixos/podman.nix`
- **Purpose**: Container runtime via Podman with Docker compatibility.
- **Key assignments**:
  - `virtualisation.containers.enable = true`.
  - `virtualisation.podman.enable = true`, `dockerCompat = true`, `dockerSocket.enable = true`, `defaultNetwork.settings.dns_enabled = true`.
  - `environment.systemPackages = [ podman-compose ]`.

### Module: `hyprland.nix`
- **File**: `modules/nixos/hyprland.nix`
- **Purpose**: Hyprland Wayland compositor integration.
- **Key assignments**:
  - `programs.hyprland.enable = true`.
  - `programs.hyprland.package = pkgs.hyprland` — nixpkgs' Hyprland package directly (currently 0.56.0, since nixpkgs-unstable 2026-07-20). No overlay or upstream flake pin needed; nixpkgs keeps up with Hyprland releases.
  - `programs.hyprland.xwayland.enable = true`.
  - `programs.hyprland.portalPackage = pkgs.xdg-desktop-portal-hyprland`.
  - `programs.hyprland.withUWSM = true`.

### Module: `nix-ld.nix`
- **File**: `modules/nixos/nix-ld.nix`
- **Purpose**: Dynamic linker support for running non-Nix binaries.
- **Key assignment**: `programs.nix-ld.enable = true`.
- **Context**: Required for VSCode in WSL and non-Nix management toolkits (FNM, UV, etc.).

### Module: `1password.nix`
- **File**: `modules/nixos/1password.nix`
- **Purpose**: 1Password GUI and CLI integration with PolKit and custom browser support (Zen Browser).
- **Key assignments**:
  - `programs._1password-gui.enable = true`, `polkitPolicyOwners = [ username ]`.
  - `programs._1password.enable = true`.
  - `environment.etc."1password/custom_allowed_browsers"` — configures `.zen` and `zen` as custom browser integrations.

### Module: `flatpak.nix`
- **File**: `modules/nixos/flatpak.nix`
- **Purpose**: Flatpak sandboxed application framework.
- **Key assignment**: `services.flatpak.enable = true`.

### Module: `localsend.nix`
- **File**: `modules/nixos/localsend.nix`
- **Purpose**: LocalSend device-to-device file sharing.
- **Key assignments**:
  - `programs.localsend.enable = true`.
  - `programs.localsend.openFirewall = true`.
