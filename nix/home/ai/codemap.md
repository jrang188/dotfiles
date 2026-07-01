# nix/home/ai/

## Responsibility

Home Manager configuration for AI/agent tooling — specifically `claude-code` and the MCP (Model Context Protocol) server registry. Installs and configures AI coding assistants and their integration points (language servers, remote APIs) for all hosts.

## Design

- **Module aggregation via `default.nix`**: The directory is imported as `./ai` from `nix/home/default.nix`. Its `default.nix` simply re-exports two child modules: `claude-code.nix` and `mcp.nix`.
- **Flake input dependency**: `claude-code.nix` depends on `inputs.llm-agents` (from `github:numtide/llm-agents.nix`) to source the `claude-code` package. This input is injected via `extraSpecialArgs` from `flake.nix`.
- **Declarative MCP server config**: `mcp.nix` uses the `programs.mcp` Home Manager module (an emerging standard) to define servers as Nix attributes. Supports both `command`-based (local binary) and `remote` (HTTP URL) server types.
- **Flat, self-contained**: No submodules or conditional logic — both AI tools are enabled unconditionally across all hosts.

## Flow

1. `nix/home/default.nix` imports `./ai`.
2. `./ai/default.nix` delegates to `./claude-code.nix` and `./mcp.nix`.
3. `claude-code.nix` sets `programs.claude-code.enable = true`, using the package from `inputs.llm-agents.packages.${system}.claude-code`, and enables MCP integration.
4. `mcp.nix` sets `programs.mcp.enable = true` and registers four servers:
   - **nixos** — local via `uvx mcp-nixos`
   - **astro** — remote at `https://mcp.docs.astro.build/mcp`
   - **kubernetes** — local via `npx kubernetes-mcp-server@latest`
   - **pulumi** — remote at `https://mcp.ai.pulumi.com/mcp`

## Integration

- **Parent**: `nix/home/default.nix` (imported as `./ai`).
- **Dependency**: `inputs.llm-agents` from `nix/flake.nix` line 56, exposed via `extraSpecialArgs`.
- **Consumers**: The `programs.claude-code` and `programs.mcp` Home Manager options, provided by the `llm-agents` flake.
- **MCP servers depend on**: `uvx` (from `uv` package in common packages), `npx` (from `nodejs` in common packages), and network access for remote servers.
