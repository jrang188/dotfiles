{ pkgs, ... }:
let
  inherit (pkgs) _1password-cli nodejs uv;
in
{
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
      opentofu = {
        type = "streamable-http";
        url = "https://mcp.opentofu.org/mcp";
      };
      grafana = {
        command = "${_1password-cli}/bin/op";
        args = [
          "run"
          "--"
          "${uv}/bin/uvx"
          "mcp-grafana"
        ];
        env = {
          GRAFANA_URL = "https://grafana.tail8255cc.ts.net";
          GRAFANA_SERVICE_ACCOUNT_TOKEN = "op://Development/victoria-metrics-grafana-admin/mcp-token";
        };
      };
    };
  };
}
