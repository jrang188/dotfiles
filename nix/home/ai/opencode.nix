_: {
  programs.opencode = {
    enable = true;
    enableMcpIntegration = true;
    settings = {
      model = "opencode-go/mimo-v2-pro";
      plugin = [
        "superpowers@git+https://github.com/obra/superpowers.git"
        "oh-my-opencode-slim"
      ];
      agent = {
        explore = {
          disable = true;
        };
        general = {
          disable = true;
        };
      };
      lsp = true;
    };
  };
}
