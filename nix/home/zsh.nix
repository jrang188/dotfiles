{...}: {
  ## MUST SET ZSH AS DEFAULT SHELL
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;

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
        "macos"
        # "uv" oh-my-zsh plugin is not installed in latest nixpkg version
      ];
    };

    syntaxHighlighting.enable = true;
    autosuggestion.enable = true;

    # Use .exe if not Darwin
    shellAliases = {
      ssh = "ssh";
      ssh-add = "ssh-add";
    };

    # The command for UV can be removed when oh-my-zsh nixpkg is updated
    initExtra = ''
      eval "$(fnm env --use-on-cd --shell zsh)"
      eval "$(uv generate-shell-completion zsh)"
    '';
  };
}
