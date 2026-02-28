_: {
  programs.mcp = {
    enable = true;
    servers = {
      nixos = {
        command = "uvx";
        args = [ "mcp-nixos" ];
      };
      astro = {
        type = "http";
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
        command = [
          "op"
          "run"
          "--env-file=$HOME/.config/.env"
        ];
        type = "http";
        url = "https://api.githubcopilot.com/mcp";
        headers = {
          Authorization = "Bearer {env:GITHUB_PAT}";
        };
      };
    };
  };
}
