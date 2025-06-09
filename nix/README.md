# Nix Dotfiles

This repository contains my personal Nix-based system configurations for macOS (Darwin), NixOS (WSL), and Ubuntu (WSL). It uses Nix flakes for reproducible and declarative system configuration.

## 🚀 Features

- **Multi-Platform Support**
  - macOS (Darwin) configuration
  - NixOS WSL configuration
  - Ubuntu WSL configuration
- **Home Manager Integration** for user-specific configurations
- **Modular Design** for easy maintenance and customization
- **Reproducible Environments** using Nix flakes

## 📋 Prerequisites

- [Nix](https://nixos.org/download.html) installed on your system
- [Home Manager](https://github.com/nix-community/home-manager) (included as a flake input)
- For macOS: [nix-darwin](https://github.com/LnL7/nix-darwin) (included as a flake input)
- For WSL: Windows Subsystem for Linux 2 (WSL2)

## 🏗️ Project Structure

```
.
├── flake.nix           # Main flake configuration
├── flake.lock         # Locked dependencies
├── hosts/             # Host-specific configurations
│   ├── darwin/       # macOS configurations
│   └── nixos/        # NixOS configurations
├── home/             # Home Manager configurations
│   ├── darwin/       # macOS-specific home configs
│   ├── nixos/        # NixOS-specific home configs
│   └── ubuntu/       # Ubuntu-specific home configs
├── modules/          # Shared Nix modules
└── Makefile         # Build and maintenance commands
```

## 🛠️ Usage

### Building Configurations

The project includes a Makefile with several useful commands:

```bash
# Build macOS configuration
make darwin

# Build NixOS WSL configuration
make nixos

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

# NixOS WSL
sudo nixos-rebuild switch --flake .#nixos-wsl

# Ubuntu WSL
home-manager switch --flake .#sirwayne
```

## 🔧 Customization

### Adding New Packages

1. For system-wide packages, add them to the appropriate host configuration in `hosts/`
2. For user-specific packages, add them to the appropriate home configuration in `home/`

### Creating New Modules

1. Create a new `.nix` file in the `modules/` directory
2. Import and use the module in your host or home configuration

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
