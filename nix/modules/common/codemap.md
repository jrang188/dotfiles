# nix/modules/common/

## Responsibility
Cross-platform system-level Nix modules that apply identically to both macOS (Darwin) and NixOS hosts. Contains configuration for base system tooling, the shared Nix daemon (Lix/GC), and font installation that is platform-agnostic.

## Design
- **Aggregation entry point**: `default.nix` re-exports three leaf modules via a standard `imports = [ ./apps.nix ./nix-core.nix ./nix-daemon.nix ]` list.
- **Flat, non-parameterized modules**: The leaf modules do not define formal Nix module options (`options` attribute). They directly assign top-level NixOS/nix-darwin option values using `environment.systemPackages`, `nix.settings`, `nixpkgs.config`, `fonts.packages`, and `programs.zsh.enable`.
- **Shared Nix daemon**: `nix-daemon.nix` holds the cross-platform Lix package and GC policy. Each platform (darwin/nixos) overlays its own timer syntax (`interval` vs `dates`) on top, so the shared core is defined once here.
- **Mostly unconditional**: Settings apply to every host that imports this module path. Platform-specific divergence (timer syntax) is handled at the darwin/ or nixos/ layer, not here.

## Flow
1. A host config imports `../../../modules/common`.
2. The Nix module system loads `modules/common/default.nix`, which adds `./apps.nix`, `./nix-core.nix`, and `./nix-daemon.nix` to the module list.
3. The leaf modules evaluate unconditionally and contribute their config to the global system configuration merge.
4. `nix-daemon.nix` sets `nix.package` (Lix), `auto-optimise-store`, and `gc.automatic`/`gc.options` with `lib.mkDefault`; darwin/nixos aggregators add their platform timer.

## Integration
- **Depends on**: `pkgs` (via function argument) — expects the nixpkgs package set passed by the caller.
- **Consumed by**: `hosts/darwin/Sterling-MBP/default.nix`, `hosts/nixos/kirby/default.nix`, `hosts/nixos/wsl/default.nix`.
- **Provides configuration for**:
  - `environment.systemPackages` (from `apps.nix`)
  - `nix.settings` — experimental-features, substituters, trusted-users (from `nix-core.nix`)
  - `nixpkgs.config` — `allowUnfree`, `allowBroken` (from `nix-core.nix`)
  - `fonts.packages` — nerd-fonts.fira-code, nerd-fonts.jetbrains-mono, font-awesome (from `nix-core.nix`)
  - `programs.zsh.enable` (from `nix-core.nix`)
  - `nix.package` (Lix), `nix.settings.auto-optimise-store`, `nix.gc.automatic`, `nix.gc.options` (from `nix-daemon.nix`)

### Module: `apps.nix`
- **File**: `modules/common/apps.nix`
- **Purpose**: Installs CLI system essentials that are useful on any Unix-like platform.
- **Packages**: `git`, `btop`, `fastfetch`, `ffmpeg`, `wget`, `curl`, `zip`, `unzip`.
- **Pattern**: Direct `environment.systemPackages` assignment with `with pkgs;` and category-comment headers.

### Module: `nix-core.nix`
- **File**: `modules/common/nix-core.nix`
- **Purpose**: Universal Nix binary cache configuration, unfree package permission, font installation, and Zsh enablement.
- **Key settings**:
  - `nix.settings.experimental-features`: enables `nix-command` and `flakes`.
  - `nix.settings.substituters` / `trusted-substituters`: Hyprland cachix.
  - `nix.settings.extra-substituters`: nix-community, cachix, hyprland, ghostty, devenv, numtide caches.
  - `nix.settings.trusted-users`: `root` and `@wheel` group.
  - `nixpkgs.config.allowUnfree = true; allowBroken = true`.
  - `fonts.packages`: Nerd Font FiraCode, JetBrains Mono, and Font Awesome.
  - `programs.zsh.enable = true` (with Darwin-specific comment about `/etc/zshrc`).

### Module: `nix-daemon.nix`
- **File**: `modules/common/nix-daemon.nix`
- **Purpose**: Shared Nix daemon configuration — the Lix package, auto-optimise-store, and GC policy. Extracted from the duplicated blocks that used to live in both `darwin/default.nix` and `nixos/default.nix`.
- **Key settings**:
  - `nix.package = pkgs.lixPackageSets.stable.lix`.
  - `nix.settings.auto-optimise-store = true`.
  - `nix.gc.automatic = true`; `nix.gc.options = lib.mkDefault "--delete-older-than 7d"`.
  - Timer syntax is NOT set here — darwin overlays `gc.interval`/`optimise.interval`, nixos overlays `gc.dates`/`optimise.automatic`.
