{ pkgs, ... }:
{
  programs.zsh.oh-my-zsh.plugins = [
    "ubuntu"
  ];

  home.packages = with pkgs; [
    git
    btop
    fastfetch
    ffmpeg
    wget
    curl
  ];

  nixpkgs.config.allowUnfree = true;
  programs.git = {
    extraConfig = {
      core.sshCommand = "ssh.exe";
    };
  };

  # Use .exe if using WSL
  shellAliases = {
    ssh = "ssh.exe";
    ssh-add = "ssh-add.exe";
  };

}
