{ pkgs, ... }:
{
  ## MUST SET ZSH AS DEFAULT SHELL
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    package = pkgs.zsh;

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "fnm"
        "bun"
        "kubectl"
        "helm"
        "terraform"
        "aws"
        "uv"
        "direnv"
        "tmux"
      ];
    };

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # The command for UV can be removed when oh-my-zsh nixpkg is updated
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
      export GOPATH=$HOME/go
      export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

      function brew() {
        command brew "$@"

        if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
          sketchybar --trigger brew_update
        fi
      }

      # # oh-my-opencode-slim tmux multiplexer: child panes attach to opencode over
      # # a TCP port, which needs an explicit --port (OpenCode >= 1.17.18 default
      # # port 0 exposes no listener).
      # function opencode() {
      #   if [[ -n "$TMUX" ]] && [[ "$*" != *"--port"* ]]; then
      #     local port
      #     port="$(python3 -c 'import socket; s=socket.socket(); s.bind(("127.0.0.1",0)); print(s.getsockname()[1]); s.close()')"
      #     command opencode --port "$port" "$@"
      #   else
      #     command opencode "$@"
      #   fi
      # }
    '';
  };
}
