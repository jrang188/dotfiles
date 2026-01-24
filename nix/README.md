# Nix Dotfiles

This repository contains my personal Nix-based system configurations for macOS (Darwin), NixOS, and Ubuntu (WSL). It uses Nix flakes for reproducible and declarative system configuration.

## 🚀 Features

- **Multi-Platform Support**
  - macOS (Darwin) configuration
  - NixOS configuration (kirby host)
  - NixOS WSL configuration
  - Ubuntu WSL configuration
- **Home Manager Integration** for user-specific configurations
- **Modular Design** for easy maintenance and customization
- **Reproducible Environments** using Nix flakes
- **Organized Structure** with clear separation of concerns

## 📋 Prerequisites

- [Nix](https://nixos.org/download.html) installed on your system
- [Home Manager](https://github.com/nix-community/home-manager) (included as a flake input)
- For macOS: [nix-darwin](https://github.com/LnL7/nix-darwin) (included as a flake input)
- For WSL: Windows Subsystem for Linux 2 (WSL2)

## 🏗️ Project Structure

```
.
├── flake.nix              # Main flake configuration
├── flake.lock             # Locked dependencies
├── hosts/                 # Host-specific system configurations
│   ├── darwin/
│   │   └── Sterling-MBP/  # macOS host config
│   └── nixos/
│       ├── kirby/         # NixOS kirby host (split into modules)
│       │   ├── default.nix      # Core system config
│       │   ├── boot.nix         # Bootloader config
│       │   ├── networking.nix   # Network config
│       │   ├── desktop.nix      # Desktop environment
│       │   ├── hardware.nix    # Hardware config (bluetooth, etc.)
│       │   ├── packages.nix    # System packages
│       │   └── secure-boot.nix # Secure boot config
│       └── wsl/            # NixOS WSL config
├── home/                  # Home Manager configurations
│   ├── default.nix         # Base config (shared by ALL systems)
│   ├── zsh.nix            # Zsh config (shared)
│   ├── neovim.nix         # Neovim config (shared)
│   ├── git.nix            # Git config (shared)
│   ├── oh-my-posh.nix     # Prompt config (shared)
│   ├── packages.nix       # Shared packages (organized by category)
│   ├── darwin/            # Darwin-specific home configs
│   ├── nixos/
│   │   ├── kirby/         # Kirby-specific home configs
│   │   │   ├── default.nix
│   │   │   ├── apps.nix          # GUI applications
│   │   │   ├── packages.nix     # Host-specific packages
│   │   │   ├── hyprland.nix     # Hyprland window manager
│   │   │   ├── rofi.nix         # Rofi launcher
│   │   │   ├── ashell.nix       # Wayland bar
│   │   │   └── zen-browser.nix # Browser config
│   │   └── wsl/          # WSL-specific home configs
│   └── ubuntu/            # Ubuntu-specific home configs
├── modules/               # Reusable Nix modules
│   ├── common/            # Shared system modules
│   ├── darwin/            # Darwin system modules
│   ├── nixos/             # NixOS system modules
│   └── home/              # Reusable home-manager modules
│       └── gui.nix        # Base GUI config (ghostty)
└── Makefile              # Build and maintenance commands
```

### Structure Principles

- **Top-level `home/` files**: Automatically imported by ALL systems
- **Platform folders** (`home/darwin/`, `home/nixos/`, `home/ubuntu/`): Platform-specific configs
- **Host folders** (`home/nixos/kirby/`): Host-specific configs
- **Modules**: Reusable configurations that must be explicitly imported

## 🛠️ Usage

### Building Configurations

The project includes a Makefile with several useful commands:

```bash
# Build macOS configuration
make darwin

# Build NixOS kirby configuration
make nixos

# Build NixOS WSL configuration
make wsl

# Build Ubuntu WSL configuration
make ubuntu

# Update flake inputs
make update

# Clean up old generations and unused packages
make clean
```

### Manual Build Commands

If you prefer not to use the Makefile, you can run the following commands directly:

```bash
# macOS
darwin-rebuild switch --flake .#Sterling-MBP

# NixOS kirby
sudo nixos-rebuild switch --flake .#kirby

# NixOS WSL
sudo nixos-rebuild switch --flake .#wsl

# Ubuntu WSL
home-manager switch --flake .#sirwayne
```

## 🔧 Customization

### Adding New Packages

1. **Shared packages** (all systems): Add to `home/packages.nix`
2. **Platform-specific packages**: Add to `home/darwin/`, `home/nixos/`, or `home/ubuntu/`
3. **Host-specific packages**: Add to `home/nixos/kirby/packages.nix` or `home/nixos/kirby/apps.nix`
4. **System packages**: Add to `hosts/nixos/kirby/packages.nix` or `modules/common/apps.nix`

Packages are organized by category with clear section headers for easy navigation.

### Creating New Modules

1. **System modules**: Create in `modules/common/`, `modules/darwin/`, or `modules/nixos/`
2. **Home modules**: Create in `modules/home/` for reusable home-manager configs
3. Import the module in the appropriate configuration file

### Adding New Hosts

1. Create host directory: `hosts/nixos/newhost/`
2. Create `default.nix` with core system config
3. Split into modules as needed (boot, networking, desktop, etc.)
4. Create home config: `home/nixos/newhost/`
5. Add to `flake.nix` with appropriate imports

## 🔄 Updating

To update your system and all flake inputs:

```bash
make update
```

## 🧹 Maintenance

Regular maintenance tasks:

1. Update flake inputs: `make update`
2. Clean up old generations: `make clean`
3. Review and update package versions
4. Check for security updates
5. Review and organize new packages by category

## 🔍 Code Quality

### Pre-commit Hooks

This repository uses [pre-commit](https://pre-commit.com/) to ensure code quality:

```bash
# Install pre-commit hooks (run once)
pre-commit install

# Run hooks manually on all files
pre-commit run --all-files

# Run hooks on staged files only (automatic on commit)
pre-commit run
```

The pre-commit hooks will:
- **Format** Nix files with `nixfmt-tree`
- **Lint** Nix files with `statix`
- Check for trailing whitespace and fix end of files
- Validate YAML and JSON files

### Manual Formatting

You can also format files manually:

```bash
# Format all Nix files
nix fmt

# Or format specific files
nixfmt-tree path/to/file.nix
```

## 📁 Package Organization

Packages are organized by category for easy maintenance:

- **Nix & Editor Tools**: Formatters, linters, language servers
- **General Utilities**: File tools, search tools, text processors
- **Programming Languages**: Runtimes, compilers, package managers
- **Development Tools**: CLI tools, linters, build tools
- **DevOps & Cloud**: Kubernetes, cloud CLIs, infrastructure tools
- **GUI Applications**: Editors, terminals, communication apps
- **System Tools**: Platform-specific utilities

## 🤝 Contributing

While this is a personal configuration, suggestions and improvements are welcome:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This configuration is tailored to my personal needs and preferences. Use at your own risk and make sure to understand the changes before applying them to your system.

## 📚 Additional Documentation

- `docs/STRUCTURE_ANALYSIS.md` - Detailed analysis of the configuration structure
- `docs/REFACTORING_SUMMARY.md` - Summary of the refactoring work completed
- See individual configuration files for inline documentation
