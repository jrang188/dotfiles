# Nix Configuration Structure Analysis

## Executive Summary

Your Nix configuration shows signs of becoming "spaghetti" with several organizational issues that make it harder to maintain. The main problems are:

1. **Deep nesting and inconsistent organization**
2. **Unclear separation between system and user configs**
3. **Mixed concerns in single files**
4. **Confusing relative import paths**
5. **Duplicate/overlapping module concepts**

---

## Current Structure Issues

### 1. **Deep Nesting in `home/nixos/kirby/`**

**Problem:**
```
home/nixos/kirby/
├── hypr/          # 4 separate files for hyprland components
├── rofi/          # Separate directory for one config
├── ashell/        # Separate directory for one config
├── apps.nix
├── packages.nix
└── default.nix
```

**Issues:**
- Unnecessary directory depth for single-purpose configs
- `hypr/` contains 4 files that could be one file or better organized
- `rofi/` and `ashell/` are single-file configs in their own directories
- Makes imports confusing: `./hypr`, `./rofi`, `./ashell`, `../../gui`

**Recommendation:**
Flatten to:
```
home/nixos/kirby/
├── hyprland.nix      # All hyprland config in one file
├── rofi.nix          # Single file
├── ashell.nix        # Single file
├── apps.nix
├── packages.nix
└── default.nix
```

### 2. **Unclear Module Separation**

**Problem:**
- `modules/nixos/hyprland.nix` - Enables hyprland system-wide
- `home/nixos/kirby/hypr/default.nix` - Contains actual hyprland config
- Unclear why hyprland config is split between system and home

**Current:**
```
modules/nixos/hyprland.nix  → System-level hyprland enable
home/nixos/kirby/hypr/      → User-level hyprland config
```

**Recommendation:**
- Keep system-level enable in `modules/nixos/hyprland.nix`
- Move all user config to `home/nixos/kirby/hyprland.nix` (flattened)
- Or create `modules/home/hyprland.nix` if it's reusable across hosts

### 3. **Mixed Concerns in Host Config**

**Problem:**
`hosts/nixos/kirby/default.nix` contains:
- Boot configuration
- Network configuration
- Desktop environment configs (Plasma, COSMIC, X11)
- Services (SSH, printing, pipewire)
- Hardware (bluetooth)
- User configuration

**Issues:**
- 150+ lines mixing multiple concerns
- Hard to find specific configurations
- Desktop environment configs should be in modules

**Recommendation:**
Split into:
```
hosts/nixos/kirby/
├── default.nix              # Core system config only
├── boot.nix                 # Bootloader config
├── networking.nix           # Network config
├── desktop.nix              # Desktop environment selection
└── hardware-configuration.nix
```

### 4. **Inconsistent Import Patterns**

**Problem:**
Mixed import styles:
- `./hypr` (directory import)
- `../../gui` (relative path, confusing)
- `../../../modules/common` (deep relative paths)
- `./packages.nix` (file import)

**Issues:**
- Hard to understand where things come from
- Relative paths break easily when moving files
- No clear convention

**Recommendation:**
Use consistent patterns:
- For same-level: `./filename.nix`
- For modules: Use absolute paths from flake or consistent relative structure
- Avoid directory imports unless truly needed

### 5. **Unclear Home Manager Organization**

**Problem:**
```
home/
├── default.nix          # Base config
├── packages.nix         # Shared packages?
├── nixos/
│   ├── kirby/
│   │   ├── apps.nix    # Host-specific apps
│   │   └── packages.nix # Host-specific packages?
│   └── wsl/
└── darwin/
```

**Issues:**
- `home/packages.nix` vs `home/nixos/kirby/packages.nix` - unclear separation
- `home/apps.nix` doesn't exist, but `home/nixos/kirby/apps.nix` does
- No clear pattern for shared vs host-specific

**Recommendation:**
Clear separation:
```
home/
├── default.nix              # Base config (zsh, git, neovim, etc.)
├── packages.nix             # Shared packages across all systems
├── nixos/
│   ├── default.nix         # NixOS-specific base config
│   ├── kirby/
│   │   ├── default.nix     # Host-specific imports
│   │   ├── apps.nix        # Host-specific apps
│   │   ├── packages.nix    # Host-specific packages
│   │   └── hyprland.nix    # Host-specific desktop config
│   └── wsl/
└── darwin/
```

### 6. **Module Organization Issues**

**Problem:**
```
modules/
├── common/          # Shared across all systems
├── darwin/          # Darwin-specific
└── nixos/           # NixOS-specific
```

**Issues:**
- `modules/nixos/` contains system-level configs
- But desktop configs are in `home/nixos/kirby/`
- Unclear when to use modules vs home configs

**Recommendation:**
Clearer module structure:
```
modules/
├── common/              # Truly shared
├── darwin/              # Darwin system modules
├── nixos/               # NixOS system modules
└── home/                # Reusable home-manager modules
    ├── hyprland.nix     # If reusable across hosts
    └── rofi.nix         # If reusable
```

---

## Recommended Structure

### Proposed Flattened Structure

```
nix/
├── flake.nix
├── flake.lock
├── hosts/
│   ├── darwin/
│   │   └── Sterling-MBP/
│   │       └── default.nix
│   └── nixos/
│       ├── kirby/
│       │   ├── default.nix      # Core system only
│       │   ├── boot.nix         # Boot config
│       │   ├── networking.nix   # Network config
│       │   ├── desktop.nix      # Desktop selection
│       │   ├── hardware-configuration.nix
│       │   └── packages.nix     # System packages
│       └── wsl/
│           └── default.nix
├── home/
│   ├── default.nix              # Base: zsh, git, neovim, etc.
│   ├── packages.nix              # Shared packages
│   ├── darwin/
│   │   └── default.nix
│   ├── nixos/
│   │   ├── default.nix          # NixOS base home config
│   │   ├── kirby/
│   │   │   ├── default.nix      # Imports all kirby configs
│   │   │   ├── apps.nix         # Host-specific apps
│   │   │   ├── packages.nix     # Host-specific packages
│   │   │   ├── hyprland.nix     # All hyprland config (flattened)
│   │   │   ├── rofi.nix         # Rofi config
│   │   │   ├── ashell.nix       # Ashell config
│   │   │   └── zen-browser.nix
│   │   └── wsl/
│   │       └── default.nix
│   └── ubuntu/
│       └── default.nix
└── modules/
    ├── common/                   # Shared system modules
    ├── darwin/                   # Darwin system modules
    ├── nixos/                    # NixOS system modules
    └── home/                     # Reusable home-manager modules
```

### Key Improvements

1. **Flattened kirby config**: All single-purpose configs are now single files
2. **Clear separation**: System configs in `hosts/`, user configs in `home/`
3. **Consistent naming**: All files use `.nix` extension, no directory imports
4. **Better modules**: Clear distinction between system and home modules
5. **Easier navigation**: Less nesting, clearer purpose

---

## Migration Steps

### Phase 1: Flatten kirby home config
1. Merge `hypr/*.nix` files into `hyprland.nix`
2. Move `rofi/default.nix` → `rofi.nix`
3. Move `ashell/default.nix` → `ashell.nix`
4. Update imports in `home/nixos/kirby/default.nix`

### Phase 2: Split kirby host config
1. Extract boot config to `boot.nix`
2. Extract networking to `networking.nix`
3. Extract desktop selection to `desktop.nix`
4. Keep only core system config in `default.nix`

### Phase 3: Organize modules
1. Create `modules/home/` for reusable home configs
2. Move reusable configs from `home/nixos/kirby/` to `modules/home/`
3. Update imports accordingly

### Phase 4: Clean up
1. Remove empty directories
2. Update README with new structure
3. Verify all builds work

---

## Benefits of Refactoring

1. **Easier navigation**: Less nesting, clearer file purposes
2. **Better maintainability**: Related configs are easier to find
3. **Reduced complexity**: Fewer relative path imports
4. **Clearer separation**: System vs user configs are obvious
5. **Easier to extend**: Adding new hosts/configs follows clear patterns

---

## Questions to Consider

1. **Is hyprland config reusable?** If yes, move to `modules/home/hyprland.nix`
2. **Are rofi/ashell kirby-specific?** If yes, keep in `home/nixos/kirby/`
3. **Should desktop configs be modules?** Consider `modules/nixos/desktop/`
4. **Can packages be better organized?** Consider splitting by category

---

## Conclusion

Your configuration has grown organically and now needs structure. The main issues are:
- Too much nesting for simple configs
- Unclear separation of concerns
- Inconsistent organization patterns

Following the recommendations above will make your config more maintainable and easier to understand.
