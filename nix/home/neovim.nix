{ pkgs, ... }:
let
  unocss-language-server = pkgs.callPackage ../pkgs/unocss-language-server.nix { };
in
{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [
      gcc
      luarocks
      tree-sitter

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
      vscode-langservers-extracted # jsonls, cssls, html, eslint
      pyright
      ruff
      rust-analyzer
      sqls
      tailwindcss-language-server
      taplo
      unocss-language-server
      terraform-ls
      typescript-language-server
      vtsls # Correct typescript language server
      vue-language-server
      yaml-language-server

      # Formatters
      prettierd
      stylua
      shfmt

      # Linters
      shellcheck
      python314Packages.flake8
      markdownlint-cli2
      markdown-toc

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
    withRuby = true;
  };
}
