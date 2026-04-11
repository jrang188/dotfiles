_: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      plugin = [ "superpowers@git+https://github.com/obra/superpowers.git" ];
    };
    tui = {
      theme = "tokyonight";
    };
  };
}
