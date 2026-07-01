# opencode/

## Responsibility

Agent configuration for OpenCode — the AI coding assistant used in this repository. Defines the agent model, plugin pipeline, MCP server registry (tool access), sub-agent presets with per-role model assignments, and skill definitions consumed by the agent runtime.

## Design

**Multi-file configuration tree:**
- `opencode.json` — Primary agent config: model selection, plugin list, MCP server registry, agent sub-type toggles, file permission grants, LSP toggle
- `oh-my-opencode-slim.json` — Multi-preset plugin config ("oh-my-opencode-slim"). Defines orchestration roles (orchestrator, oracle, council, librarian, explorer, designer, fixer, observer) with model, variant, skill, and MCP assignments. Two presets: `openai` and `opencode-go`
- `tui.json` — Terminal UI theme: sets `tokyonight`
- `settings.json` — Empty placeholder (no user overrides)
- `.gitignore` — Excludes runtime artifacts: `agents/`, `command/`, `get-shit-done/`, `hooks/`, `plugins/`, `node_modules/`, lockfiles

**Agent configuration (`opencode.json`):**

| Key | Value | Notes |
|---|---|---|
| `model` | `opencode-go/mimo-v2-pro` | Default model for the agent |
| `plugin` | `["superpowers@git+...", "oh-my-opencode-slim"]` | Two plugins loaded: superpowers (from GitHub) + local slim preset |
| `lsp` | `true` | LSP integration enabled |
| `agent.explore.disable` | `true` | Explore sub-agent turned off |
| `agent.general.disable` | `true` | General sub-agent turned off |

**MCP server registry** (under `mcp` key):

| Server | Type | Endpoint | Enabled |
|---|---|---|---|
| `nixos` | `local` | `uvx mcp-nixos` | yes |
| `astro` | `remote` | `https://mcp.docs.astro.build/mcp` | yes |
| `kubernetes` | `local` | `npx -y kubernetes-mcp-server@latest` | yes |
| `pulumi` | `remote` | `https://mcp.ai.pulumi.com/mcp` | yes |

**Permission grants** (`permission` key): Read and external-directory access allowed for `~/.config/opencode/gsd-core/*`.

**Preset plugin (`oh-my-opencode-slim.json`):**

Two presets, each defining sub-agent roles:

| Role | `openai` preset model | `opencode-go` preset model | Skills | MCPs |
|---|---|---|---|---|
| orchestrator | `openai/gpt-5.5` | `opencode-go/glm-5.2` | `*` | all except context7 |
| oracle | `openai/gpt-5.5` (high) | `opencode-go/deepseek-v4-pro` (max) | `simplify` | none |
| council | — | `opencode-go/deepseek-v4-pro` (high) | none | none |
| librarian | `openai/gpt-5.4-mini` (low) | `opencode-go/minimax-m3` | none | websearch, context7, grep_app |
| explorer | `openai/gpt-5.4-mini` (low) | `opencode-go/minimax-m3` | none | none |
| designer | `openai/gpt-5.4-mini` (medium) | `opencode-go/kimi-k2.6` (medium) | agent-browser | none |
| fixer | `openai/gpt-5.4-mini` (low) | `opencode-go/deepseek-v4-flash` (high) | none | none |
| observer | — | `opencode-go/kimi-k2.6` | none | none |

**Skills directory** (`skills/`): Contains three custom skill packages, each with a `SKILL.md`, `README.md`, and `codemap.md`:

| Skill | Purpose (from SKILL.md) |
|---|---|
| `clonedeps/` | Cloning dependency repositories |
| `codemap/` | Building and maintaining codemap documentation files (includes `scripts/` subdirectory) |
| `simplify/` | Simplifying / refactoring code |

## Flow

1. **Agent launch**: OpenCode reads `opencode.json`, selects the model, loads plugins (superpowers + oh-my-opencode-slim), and initializes the MCP servers.
2. **Preset selection**: `oh-my-opencode-slim.json` provides a preset (active: `opencode-go`). The orchestrator role dispatches tasks to sub-agents (oracle, librarian, explorer, designer, fixer, observer) each with a distinct model, variant/effort, skill set, and MCP access.
3. **MCP tool invocation**: When the agent needs domain-specific data (NixOS package info, Astro docs, Kubernetes cluster state, Pulumi infrastructure), it routes the request to the appropriate MCP server.
4. **Skill execution**: Sub-agents load skills from the `skills/` directory or from the `oh-my-opencode-slim` plugin. The `simplify` skill is specifically assigned to the oracle role.

## Integration

| Consumer / Dependency | Mechanism | Details |
|---|---|---|
| **OpenCode runtime** | `opencode.json` | Primary config consumed by the OpenCode CLI; determines model, plugins, MCPs, permissions |
| **oh-my-opencode-slim plugin** | Plugin system | JSON config loaded as a plugin; defines sub-agent role topology and model routing |
| **MCP servers (external)** | `mcp` key in `opencode.json` | NixOS (local uvx), Astro (remote), Kubernetes (local npx), Pulumi (remote) — each provides domain-specific tools to the agent |
| **Superpowers plugin** | `plugin` key | GitHub-hosted plugin providing meta-skills for agent orchestration |
| **Home Manager (`nix/home/ai/`)** | Nix modules | Companion Nix configs for `claude-code` and `mcp` servers; referenced from `AGENTS.md` |
| **Stow / dotfiles** | `.gitignore` | Lockfiles and runtime artifacts excluded from version control |
