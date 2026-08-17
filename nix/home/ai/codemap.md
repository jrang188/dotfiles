# nix/home/ai/

## Responsibility

Home Manager configuration for AI/agent tooling — `claude-code`, `opencode`, `antigravity-cli`, and the MCP (Model Context Protocol) server registry. Installs and configures AI coding assistants and their integration points (language servers, remote APIs) for all hosts.

## Design

- **Module aggregation via `default.nix`**: The directory is imported as `./ai` from `nix/home/default.nix`. Its `default.nix` re-exports four child modules: `claude-code.nix`, `mcp.nix`, `opencode.nix`, and `antigravity.nix`.
- **Flake input dependency**: `claude-code.nix` and `opencode.nix` depend on `inputs.llm-agents` (from `github:numtide/llm-agents.nix`) to source their packages. This input is injected via `extraSpecialArgs` from `flake.nix`.
- **Single source of truth for MCP servers**: `mcp.nix` defines the server registry once in `programs.mcp.servers`. Both `claude-code.nix` (`enableMcpIntegration`) and `opencode.nix` (`enableMcpIntegration`) consume it, so adding/removing a server requires editing only `mcp.nix`.
- **opencode config is Nix-managed**: `opencode.nix` sets `programs.opencode.settings` and `programs.opencode.tui`, which Home Manager writes to `~/.config/opencode/opencode.json` and `~/.config/opencode/tui.json` at build time. The stowed `opencode/opencode.json` and `opencode/tui.json` are gitignored and no longer edited by hand.
- **Flat, self-contained**: No submodules or conditional logic — the AI tools are enabled unconditionally across all hosts.

## Flow

1. `nix/home/default.nix` imports `./ai`.
2. `./ai/default.nix` delegates to `./claude-code.nix`, `./mcp.nix`, `./opencode.nix`, and `./antigravity.nix`.
3. `claude-code.nix` sets `programs.claude-code.enable = true`, using the package from `inputs.llm-agents.packages.${system}.claude-code`, enables MCP integration, and adds `pkgs.claude-agent-acp` to `home.packages`.
4. `opencode.nix` sets `programs.opencode.enable = true`, using the `inputs.llm-agents.packages.${system}.opencode` package, enables MCP integration, and declares model/plugin/agent/lsp settings plus the TUI theme (`tui.theme = "tokyonight"`).
5. `antigravity.nix` enables `programs.antigravity-cli` with MCP integration.
6. `mcp.nix` sets `programs.mcp.enable = true` and registers five servers (the single source of truth for both consumers):
   - **nixos** — local via `uvx mcp-nixos`
   - **astro** — remote at `https://mcp.docs.astro.build/mcp`
   - **kubernetes** — local via `npx kubernetes-mcp-server@latest`
   - **opentofu** — remote streamable-http at `https://mcp.opentofu.org/mcp`
   - **grafana** — local via 1Password-injected `uvx mcp-grafana` against `grafana.tail8255cc.ts.net`

## Integration

- **Parent**: `nix/home/default.nix` (imported as `./ai`).
- **Dependency**: `inputs.llm-agents` from `nix/flake.nix` line 56, exposed via `extraSpecialArgs`.
- **Consumers**: The `programs.claude-code`, `programs.opencode`, and `programs.mcp` Home Manager options, provided by the `llm-agents` flake.
- **MCP integration**: `programs.mcp.servers` feeds both `programs.claude-code.mcpServers` and `programs.opencode.settings.mcp` via `enableMcpIntegration` on each.
- **MCP servers depend on**: `uvx` (from `uv` package in common packages), `npx` (from `nodejs` in common packages), `_1password-cli` (for grafana credential injection), and network access for remote servers.
