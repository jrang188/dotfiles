{ pkgs, ... }:
{
  home.packages = with pkgs; [
    # ============================================
    # Code Editors & IDEs
    # ============================================
    code-cursor # Cursor IDE
    vscode # Visual Studio Code
    zed-editor # Zed Editor
    jetbrains.idea-oss # Intellij IDEA

    # ============================================
    # Terminals
    # ============================================
    kitty # Terminal emulator
    warp-terminal # Modern terminal

    # ============================================
    # Development & Productivity Tools
    # ============================================
    httpie # HTTP client
    obsidian # Note-taking app
    notion-app-enhanced # Notion client
    ticktick # Task management

    # ============================================
    # Communication & Collaboration
    # ============================================
    discord # Discord client
    webcord # Discord web client
    vesktop # Discord client (Vesktop)
    zoom-us # Video conferencing

    # ============================================
    # Media & Entertainment
    # ============================================
    spotify # Music streaming

    # ============================================
    # Office & Productivity
    # ============================================
    libreoffice # Office suite
    xournalpp # PDF editor

    # ============================================
    # Browsers
    # ============================================
    microsoft-edge # Microsoft Edge browser

    # ============================================
    # Container & Virtualization
    # ============================================
    podman-desktop # Podman desktop client

    # ============================================
    # Gaming & Entertainment
    # ============================================
    prismlauncher # Minecraft launcher

    # ============================================
    # System Tools
    # ============================================
    blueman # Bluetooth manager
  ];
}
