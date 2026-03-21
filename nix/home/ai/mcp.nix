_: {
  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
      astro = {
        type = "remote";
        url = "https://mcp.docs.astro.build/mcp";
      };
      kubernetes = {
        command = "npx";
        args = [
          "-y"
          "kubernetes-mcp-server@latest"
        ];
      };
      pulumi = {
        "type" = "remote";
        "url" = "https://mcp.ai.pulumi.com/mcp";
      };
    };
  };
}
