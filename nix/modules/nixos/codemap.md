# nix/modules/nixos/

## Responsibility
NixOS-specific system modules for the `kirby` host. Configures containerization (Podman), desktop environment (Hyprland), package management infrastructure (nix-ld), sandboxed application delivery (Flatpak), password management (1Password), device-to-device sharing (LocalSend), and Nix daemon housekeeping (GC, optimization). These modules are only meaningful in a Linux/NixOS context.

## Design
- **Aggregation entry point**: `default.nix` imports six leaf modules and inlines Nix daemon GC/optimization configuration.
- **Single-purpose leaf modules**: Each `.nix` file focuses on one concern (e.g. `podman.nix` for containerization, `hyprland.nix` for the compositor). This follows the project convention of modularizing by service/tool.
- **No option declarations**: All leaf modules assign existing NixOS option values directly without defining custom options. The module interface is purely the NixOS options namespace.
- **Direct `_` function pattern**: Several modules (`flatpak.nix`, `nix-ld.nix`, `localsend.nix`) use `_: { ... }` — ignoring function arguments entirely — indicating self-contained configs with no external dependencies.
- **Conditional patterns not needed**: Since these modules are exclusive to NixOS, there is no need for `mkIf` platform gating. The `default.nix` inlines Nix GC settings using `lib.mkDefault` for graceful override by host configs.

## Flow
1. `hosts/nixos/kirby/default.nix` imports `../../../modules/nixos`.
2. Nix resolves to `modules/nixos/default.nix`, which:
   - Imports all six leaf modules.
   - Sets `nix.optimise.automatic = true`, `nix.settings.auto-optimise-store = true`.
   - Configures `nix.gc` with `automatic = true`, `dates = "Daily"`, and a `lib.mkDefault "--delete-older-than 7d"` option.
   - Configures `nix.settings.eval-cores = 0`.
   - Sets `users.defaultUserShell = pkgs.zsh`.
3. Each leaf module evaluates independently and contributes config to the global NixOS configuration merge.

## Integration
- **Depends on**: `pkgs`, `lib` (in default.nix); `inputs` (in hyprland.nix for the pinned Hyprland package); `username` (in 1password.nix for PolKit owner).
- **Consumed by**: `hosts/nixos/kirby/default.nix`.
- **Not consumed by**: The orphaned `hosts/nixos/wsl/default.nix` imports `common` only, not `nixos` — the WSL host config manually duplicates some settings (Nix GC, auto-optimise, default shell) rather than importing this module set.
- **Complemented by**: `modules/common` (separately imported by the host) for cross-platform Nix and font settings.

### Module: `default.nix`
- **File**: `modules/nixos/default.nix`
- **Purpose**: Module aggregation + Nix daemon GC/housekeeping.
- **Imports**: `flatpak.nix`, `nix-ld.nix`, `1password.nix`, `hyprland.nix`, `podman.nix`, `localsend.nix`.
- **Inline assignments**:
  - `nix.optimise.automatic = true`.
  - `nix.settings.auto-optimise-store = true`.
  - `nix.gc.automatic = true`, `nix.gc.options = lib.mkDefault "--delete-older-than 7d"`, `nix.gc.dates = "Daily"`.
  - `nix.settings.eval-cores = 0`.
  - `users.defaultUserShell = pkgs.zsh`.

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
  - `programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland` — uses the flake-pinned Hyprland input (currently v0.54.3, with the kirby host using a Hyprland pinned to 0.53.3 via overlay for `hy3` compat).
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
