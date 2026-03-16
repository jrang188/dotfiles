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
      github = {
        command = "op";
        args = [
          "run"
          "--"
          "docker"
          "run"
          "-i"
          "--rm"
          "-e"
          "GITHUB_PERSONAL_ACCESS_TOKEN"
          "ghcr.io/github/github-mcp-server"
        ];
        env = {
          GITHUB_PERSONAL_ACCESS_TOKEN = "op://Development/Github MCP PAT/token";
        };
      };
      pulumi = {
        "type" = "remote";
        "url" = "https://mcp.ai.pulumi.com/mcp";
      };
    };
  };
}
