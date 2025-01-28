{ ... }:
{
  programs.zsh = {
    # Use .exe if using WSL
    shellAliases = {
      ssh = "ssh.exe";
      ssh-add = "ssh-add.exe";
    };
  };

  nixpkgs.config.allowUnfree = true;
  programs.git = {
    extraConfig = {
      core.sshCommand = "ssh.exe";
    };
  };
}
