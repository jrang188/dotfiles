{ pkgs, ... }:
let
  unocss-language-server = pkgs.callPackage ../pkgs/unocss-language-server.nix { };

  # debugpy 1.8.22 adds test_add_code_to_python_process.py::test_lldb_command, which
  # asserts the lldb attach command starts with the bare "lldb" name. nixpkgs'
  # hardcode-lldb.patch rewrites it to the store path, so the test fails on Darwin.
  # Fixed upstream in NixOS/nixpkgs#572564 (merged 2026-10-11) but not yet on the
  # nixpkgs-unstable branch this flake tracks. Remove this override once it lands.
  debugpy = pkgs.python314Packages.debugpy.overrideAttrs (old: {
    disabledTestPaths =
      (old.disabledTestPaths or [ ])
      ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
        "tests/debugpy/server/test_add_code_to_python_process.py::test_lldb_command"
      ];
  });
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
      debugpy

      # Misc tools
      ripgrep # for snacks_picker/telescope
      fd # for snacks_picker/telescope
      lsof # for process detection
    ];
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
    sideloadInitLua = true;
  };
}
