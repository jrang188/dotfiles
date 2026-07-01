# aerospace/

## Responsibility

Declarative configuration for AeroSpace, a macOS tiling window manager. Defines workspace layout, key bindings, window management rules, gaps, monitor assignments, and user-level startup hooks. Sketches the window tree behavior and integrates with macOS native windowing.

## Design

Single-file TOML config (`aerospace.toml`) placed at `~/.aerospace.toml` via stow. All settings are AeroSpace built-in keys — no custom modules or layering.

Key architectural patterns:

- **Binding modes**: A two-mode state machine (`main` and `service`). The `main` mode handles normal tiling operations (focus, move, resize, workspace switching). The `service` mode provides administrative commands (config reload, layout reset, floating toggle, close-all-but-current). Mode transitions are tracked via SketchyBar triggers (`aerospace_enter_service_mode` / `aerospace_leave_service_mode`).
- **Startup lifecycle**: `start-at-login = true` triggers the `after-startup-command` sequence, which launches `borders` (JankyBorders with TokyoNight colors) and `sketchybar` (status bar). These are `exec-and-forget` — AeroSpace does not track their lifetimes.
- **Workspace-to-monitor assignment**: Named workspaces (Dev, Web, Shell, Comms, Note, Utility, Media) are pinned to `primary` or `secondary` monitors via `workspace-to-monitor-force-assignment`. Numeric workspaces (1-9) are unconstrained.
- **Window detection rules**: `[[on-window-detected]]` blocks match `app-id` and auto-move windows to named workspaces (e.g., Slack → Comms, Spotify → Media, Obsidian → Note). No floating / sizing rules — only workspace assignment.
- **Gaps**: Inner gaps (10px) are uniform; outer gaps vary by monitor (built-in gets 10px bottom, 20px top; all others get 10px bottom, 50px top).

## Flow

1. **Login → AeroSpace startup**: macOS launches AeroSpace (via `start-at-login`). AeroSpace runs `after-startup-command`: `exec-and-forget borders ...` then `exec-and-forget sketchybar`.
2. **Window creation**: When a new window is detected, `[[on-window-detected]]` rules are evaluated in order. If `app-id` matches, the window is moved to the specified workspace via `move-node-to-workspace`.
3. **User interaction**: Key bindings in `[mode.main.binding]` dispatch AeroSpace commands (focus, move, resize, workspace switch). `alt-shift-;` enters `service` mode; `esc` returns to `main` mode.
4. **Focus/workspace change → SketchyBar**: Two event callbacks notify SketchyBar:
   - `exec-on-workspace-change` → `sketchybar --trigger aerospace_workspace_change` with `FOCUSED_WORKSPACE` and `FOCUSED_DISPLAY`.
   - `on-focus-changed` → `exec-and-forget sketchybar --trigger aerospace_focus_change`.
5. **Monitor focus change**: `on-focused-monitor-changed` moves the mouse to monitor-lazy-center.

## Integration

| Consumer / Dependency | Mechanism | Details |
|---|---|---|
| **SketchyBar** (`sketchybar/`) | `after-startup-command` | Launched via `exec-and-forget sketchybar` |
| **SketchyBar event callbacks** | `exec-on-workspace-change`, `on-focus-changed` | Fires `aerospace_workspace_change` and `aerospace_focus_change` triggers with workspace/display env vars |
| **SketchyBar mode tracking** | `[mode.main.binding]` / `[mode.service.binding]` | `aerospace_enter_service_mode` / `aerospace_leave_service_mode` triggers |
| **JankyBorders** (`borders`) | `after-startup-command` | Launched via `exec-and-forget borders ...` with TokyoNight color scheme (`0xffc0caf5` / `0xff414868`) |
| **macOS** | `start-at-login` | AeroSpace starts at login; no Nix/Darwin module wraps this |
| **Stow** | `.stowrc` | `aerospace/` is symlinked into `~/.config/aerospace/` (but the file must also be copied to `~/.aerospace.toml` as noted in the config header) |
