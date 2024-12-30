#!/bin/bash

# This script only install Oh My Zsh, Oh My Posh, Fira Code Nerd Font and Neovim.

# Exit on error
set -e

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
else
    echo "Unsupported operating system"
    exit 1
fi

echo "Setting up development environment for $OS..."

install_stow() {
    if ! command -v stow &>/dev/null; then
        echo "Installing stow..."
        if [ "$OS" == "macos" ]; then
            brew install stow
        else
            sudo apt update
            sudo apt install -y stow
        fi
    fi
}

# Function to install Zsh
install_zsh() {
    if ! command -v zsh &>/dev/null; then
        echo "Installing Zsh..."
        if [ "$OS" == "macos" ]; then
            brew install zsh
        else
            sudo apt update
            sudo apt install -y zsh
        fi
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
}

# Function to install Oh My Posh
install_oh_my_posh() {
    echo "Installing Oh My Posh..."
    if [ "$OS" == "macos" ]; then
        brew install jandedobbeleer/oh-my-posh/oh-my-posh
    else
        curl -s https://ohmyposh.dev/install.sh | bash -s
    fi
}

# Function to install Fira Code Nerd Font
install_font() {
    echo "Installing Fira Code Nerd Font..."
    if [ "$OS" == "macos" ]; then
        brew tap homebrew/cask-fonts
        brew install --cask font-firacode-nerd-font
    else
        oh-my-posh font install FiraCode
    fi
}

install_neovim() {
    echo "Installing Neovim..."
    if [ "$OS" == "macos" ]; then
        brew install neovim
    else
        sudo apt update
        sudo apt install -y neovim
    fi
}

# Install Homebrew on macOS if needed
if [ "$OS" == "macos" ]; then
    if ! command -v brew &>/dev/null; then
        echo "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for M1 Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >>~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
    fi
fi

# Install required packages on Ubuntu
if [ "$OS" == "linux" ]; then
    sudo apt update
    sudo apt install -y curl wget software-properties-common git build-essential
fi

# Run installation steps
install_stow
install_zsh # Oh My Zsh requires Zsh to be installed first
install_oh_my_zsh
install_oh_my_posh
install_font
install_neovim

echo "Installation complete!"
echo "Please restart your terminal for changes to take effect."
echo "You may need to manually select FiraCode Nerd Font in your terminal preferences."
echo "Don't forget to run stow ."