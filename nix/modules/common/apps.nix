{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    # ============================================
    # System Essentials
    # ============================================
    git # Version control
    btop # System monitor
    fastfetch # System information tool

    # ============================================
    # Network & Media Tools
    # ============================================
    ffmpeg # Multimedia framework
    wget # Web downloader
    curl # Web transfer tool

    # ============================================
    # Archive Tools
    # ============================================
    zip # ZIP archiver
    unzip # ZIP extractor
  ];
}
