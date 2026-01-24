{ pkgs, ... }: {
  programs.zsh = {
    oh-my-zsh.plugins = [ "ubuntu" ];
    # Use .exe if using WSL
    shellAliases = {
      ssh = "ssh.exe";
      ssh-add = "ssh-add.exe";
    };
    initContent = ''
      nvim() {
          if ! pidof socat > /dev/null 2>&1; then
              [ -e /tmp/discord-ipc-0 ] && rm -f /tmp/discord-ipc-0
              socat UNIX-LISTEN:/tmp/discord-ipc-0,fork EXEC:"/mnt/c/bin/npiperelay.exe //./pipe/discord-ipc-0" &
          fi

          if [ $# -eq 0 ]; then
              command nvim
          else
              command nvim "$@"
          fi
      }

      vim() { nvim "$@"; }
    '';
  };

  home.packages = with pkgs; [
    git
    btop
    fastfetch
    ffmpeg
    wget
    curl
    socat
    clang
  ];

  programs.git = { extraConfig = { core.sshCommand = "ssh.exe"; }; };
}
