{ pkgs-unstable, ... }:
{
  ## MUST SET ZSH AS DEFAULT SHELL
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;
    package = pkgs-unstable.zsh;

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
        # "uv" oh-my-zsh plugin is not installed in latest nixpkg version
      ];
    };

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # The command for UV can be removed when oh-my-zsh nixpkg is updated
    initExtra = ''
      eval "$(fnm env --use-on-cd --shell zsh)"
      eval "$(uv generate-shell-completion zsh)"
    '';
  };
}
