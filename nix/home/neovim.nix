{ pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      gcc

      # LSPs
      astro-language-server
      basedpyright
      docker-compose-language-service
      dockerfile-language-server
      gopls
      helm-ls
      jdt-language-server
      kotlin-language-server
      marksman
      nixd
      nixfmt
      nodePackages.vscode-langservers-extracted # jsonls, cssls, html, eslint
      pyright
      ruff
      rust-analyzer
      sqls
      tailwindcss-language-server
      taplo
      terraform-ls
      typescript-language-server
      vue-language-server
      yaml-language-server

      # Formatters
      prettierd
      stylua
      shfmt

      # Linters
      shellcheck
      python314Packages.flake8

      # DAP (debugging)
      delve # Go debugger
      python314Packages.debugpy

      # Misc tools
      ripgrep # for snacks_picker/telescope
      fd # for snacks_picker/telescope
      lsof # for process detection
    ];
    withNodeJs = true;
    withPython3 = true;
  };
}
