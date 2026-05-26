---
title: Concerns & Technical Debt
last_mapped: 2026-05-26
---

# Concerns & Technical Debt

## High Priority

### 1. Hyprland Pinned to Stale nixpkgs Commit

**Location:** `nix/flake.nix:44`, `nix/hosts/nixos/kirby/default.nix:13-23`

```nix
nixpkgsHyprland.url = "github:NixOS/nixpkgs/dd9b079222d43e1943b6ebd802f04fd959dc8e61";
```

**Problem:** Entire `nixpkgs` is pinned to a specific commit to keep Hyprland at 0.53.3 for hy3 compatibility. This means kirby receives two nixpkgs evaluations (the pinned one + main nixos-unstable), increasing eval time and binary cache misses. The hyprland/hyprlandPlugins packages come from this stale channel.

**Root cause:** hy3 0.53.0.1 is incompatible with Hyprland 0.54.x API changes.

**Resolution:** Remove the pin and the overlay once hy3 releases a version supporting Hyprland 0.54.x. The comment in `flake.nix` confirms this is known.

---

### 2. WSL / Ubuntu Configurations Orphaned

**Location:** `nix/hosts/nixos/wsl/`, `nix/home/nixos/wsl/`, `nix/home/ubuntu/`

**Problem:** Code exists for NixOS WSL and Ubuntu (home-manager only) configurations, but neither appears in `flake.nix` outputs. These configurations can silently rot — Nix option changes, package renames, etc. will go undetected because nothing ever builds them.

**Impact:** Low day-to-day, high if someone tries to use them.

**Resolution:** Either add them to `flake.nix` outputs or delete the directories.

---

### 3. `allowBroken = true` Set Globally

**Location:** `nix/modules/common/nix-core.nix:29-32`

```nix
nixpkgs.config = {
  allowUnfree = true;
  allowBroken = true;   # ← this
};
```

**Problem:** `allowBroken = true` suppresses build errors for packages marked broken in nixpkgs. This is applied to all hosts, meaning broken packages can be silently installed without warning. Combined with `nixos-unstable`, this is a reliability risk.

**Resolution:** Remove `allowBroken = true` globally; re-add it per-package or per-host where actually needed.

---

## Medium Priority

### 4. Hardcoded Hook Paths in Claude Code Settings

**Location:** `claude/settings.json`

All hook commands reference `"/Users/sirwayne/.claude/hooks/..."` as absolute paths. If `~/.claude` is symlinked from dotfiles (the planned state), these paths will resolve correctly via the symlink. However, the paths are not portable to other machines or usernames.

**Note:** The nix store path issue (`/nix/store/<hash>/bin/node`) was already fixed — hooks now use `node` (PATH-resolved).

**Resolution:** Acceptable as-is for single-user dotfiles. Would need templating if shared.

---

### 5. Duplicate Nix LSPs

**Location:** `nix/home/packages.nix:12-13`

```nix
nil   # Nix language server
nixd  # Another Nix language server
```

Both `nil` and `nixd` are installed. They serve the same purpose and can conflict in editors. Only one is needed.

**Resolution:** Pick one (nixd is more actively maintained) and remove the other.

---

### 6. Duplicate Nix Formatters

**Location:** `nix/home/packages.nix:14-15`

```nix
nixfmt       # Nix formatter
nixfmt-tree  # Nix formatter (tree-sitter based)
```

Both `nixfmt` and `nixfmt-tree` are installed as packages. The flake's `formatter` output also references `nixfmt`. The pre-commit hook uses `treefmt` (which invokes `nixfmt-tree`). Unclear which is canonical.

**Resolution:** Standardize on one formatter. The flake `formatter` output suggests `nixfmt` is intended, but pre-commit uses `nixfmt-tree` via treefmt.

---

### 7. Hyprland + KDE Dual Desktop on kirby

**Location:** `nix/home/nixos/kirby/` (both `hyprland.nix` and `kde.nix` imported)

**Problem:** Both Hyprland and KDE Plasma are configured as home-manager modules for the same user. Running two desktop environments is unusual and can cause conflicts (polkit agents, theming, display manager session selection).

**Impact:** Likely harmless if only one is launched at a time, but adds package bloat and potential session conflicts.

---

### 8. `auto-upgrade` Commented Out with Hardcoded Path

**Location:** `nix/hosts/nixos/kirby/default.nix:62-75`

```nix
# system.autoUpgrade = {
#   enable = true;
#   flake = "/home/${username}/dotfiles/nix#kirby";
#   ...
```

The commented-out `autoUpgrade` config uses a hardcoded filesystem path (`/home/${username}/dotfiles/nix`). Even if uncommented, this assumes the dotfiles are at a fixed location.

---

### 9. Wallpaper Paths Use Tilde Shorthand

**Location:** `nix/home/nixos/kirby/hyprland.nix:267`, `:363`

```nix
path = "~/dotfiles/wallpapers/spiderverse.jpg";
```

Tilde paths (`~/dotfiles/`) are not managed by Nix and rely on the dotfiles being checked out at `$HOME/dotfiles`. If the repo moves, wallpaper references break silently (hyprlock/hyprpaper will fall back to a blank/black background).

**Resolution:** Use `config.home.homeDirectory` + a proper path construction, or manage wallpapers via `home.file`.

---

### 10. Darwin Dock Mixes Nix Store and Homebrew Paths

**Location:** `nix/hosts/darwin/Sterling-MBP/default.nix:30-39`

```nix
system.defaults.dock.persistent-apps = [
  "System/Applications/Apps.app"
  "/Applications/Zen Browser.app"       # ← Homebrew / external
  "${pkgs.ghostty-bin}/Applications/Ghostty.app"  # ← Nix store
  "/Applications/Zed.app"               # ← Homebrew
  ...
];
```

Nix store paths for dock items change every rebuild (hash changes), causing dock entries to break or duplicate on `darwin-rebuild switch`. Apps installed outside Nix (`/Applications/Zen Browser.app`) must exist at that path.

---

## Low Priority

### 11. Java/Gradle/Maven Applied to All Hosts

**Location:** `nix/home/packages.nix:44-46`

```nix
javaPackages.compiler.temurin-bin.jdk-21
gradle
maven
```

These are in the shared `packages.nix`, so they're installed on all hosts including any WSL/Ubuntu config. Java tooling is heavy (~500MB+). Could be moved to a Darwin-specific or per-project `devenv`/`shell.nix`.

---

### 12. No CI Pipeline

**Location:** No `.github/workflows/`, no CI config anywhere.

Configuration changes are validated only when manually run on the target machine. A GitHub Actions workflow running `nix flake check` on push would catch evaluation errors before they reach a machine.

---

### 13. MCP Server Runtime Fetch

**Location:** `nix/home/ai/mcp.nix:14-19`

```nix
kubernetes = {
  command = "npx";
  args = [ "-y" "kubernetes-mcp-server@latest" ];
};
```

The Kubernetes MCP server is fetched via `npx ... @latest` at runtime — not pinned. This means it can silently update (or break) without any config change. Remote MCP servers (astro, pulumi) are similarly unversioned URLs.

---

## Security Notes

- `allowUnfree = true` globally — accepts license risk for all hosts
- `allowBroken = true` globally — suppresses package integrity checks
- DNSCrypt minisign public key hardcoded in `nix/hosts/nixos/kirby/networking.nix` — no rotation mechanism
- `nix.settings.trusted-users = [ username ]` on all hosts — gives the user trusted Nix daemon access (expected for dotfiles, but worth noting)
- 1Password is integrated at system level (NixOS module), giving it full system access for secrets management
