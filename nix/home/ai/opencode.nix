{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;

  # OpenCode v2 (npm @opencode/cli line). The llm-agents package only ships
  # bin/opencode2, while upstream exposes both `opencode` and `opencode2`
  # bin names — alias `opencode` so the standard command keeps working and
  # runs v2. v1 and v2 cannot be installed side by side anyway.
  opencode-v2 = inputs.llm-agents.packages.${system}.opencode2;
in
{
  programs.opencode = {
    enable = true;
    package = pkgs.symlinkJoin {
      name = "${opencode-v2.name}-aliased";
      inherit (opencode-v2) meta;
      paths = [ opencode-v2 ];
      postBuild = ''
        ln -s opencode2 $out/bin/opencode
      '';
    };
    enableMcpIntegration = true;
    # Native v2 config keys. Dropped `lsp = true` (v2 accepts the key but
    # runs no language servers, exposes no LSP tools, and produces no
    # diagnostics); flat v1 `mcp` from enableMcpIntegration still works.
    settings = {
      model = "opencode-go/mimo-v2.5";
      plugins = [
        "oh-my-opencode-slim"
      ];
      agents = {
        explore = {
          disabled = true;
        };
        general = {
          disabled = true;
        };
      };
      # oh-my-opencode-slim: v2 hosts cap subagent nesting at 1 by default;
      # raise it so advisor subagents (explorer/oracle) can read images.
      experimental = {
        subagent_depth = 2;
      };
    };
  };

  # v2 replaces v1's layered tui.json with one global cli.json
  # (theme lives under theme.name). Writing cli.json directly skips v2's
  # one-shot tui.json auto-migration and keeps the theme declarative.
  xdg.configFile."opencode/cli.json".text = builtins.toJSON {
    "$schema" = "https://opencode.ai/v2/cli.json";
    theme = {
      name = "tokyonight";
    };
  };
}
