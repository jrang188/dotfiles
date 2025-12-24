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
      ];
    };

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # The command for UV can be removed when oh-my-zsh nixpkg is updated
    initContent = ''
      eval "$(fnm env --use-on-cd --shell zsh)"
      export PATH="$HOME/.local/bin:$PATH"
      export GOPATH=$HOME/go
      export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

      function brew() {
        command brew "$@"

        if [[ $* =~ "upgrade" ]] || [[ $* =~ "update" ]] || [[ $* =~ "outdated" ]]; then
          sketchybar --trigger brew_update
        fi
      }
    '';
  };
}
