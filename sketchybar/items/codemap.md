# sketchybar/items/

## Responsibility

Bar item definition and registration. Each Lua module in this directory declares one or more sketchybar items (including brackets, popups, spacers) and wires their event subscriptions. This is the primary **UI component layer** — it translates system events into visible bar state changes.

## Design

- **Declarative Item Registration**: Each file calls `sbar.add(type, name?, config)` to create items. Types used: `"item"` (text/icon), `"bracket"` (visual grouping with shared background), and graph/popup variants. Items are positioned either on the bar or inside a popup via `position = "popup.<parent_name>"`.
- **Observer Pattern via Event Subscriptions**: Items subscribe to sketchybar events using `item:subscribe(event_names, callback)`. The sketchybar daemon delivers events asynchronously via Mach IPC; callbacks receive an `env` table with event-specific keys. Multiple items can subscribe to the same event.
- **Bracket Wrapping for Borders**: Several items (`apple.lua`, `calendar.lua`) use a bracket containing a single item to achieve a **double-border** visual effect — the bracket provides an outer border, the item provides an inner border.
- **Padding Items for Layout**: Spacer items (zero-width or fixed-width) are inserted before/after bracketed groups to maintain consistent spacing. This is a consequence of brackets consuming their children's outer margins.
- **Orchestrated Registration**: `items/init.lua` requires modules in order: `apple` → `workspaces` → `front_app` → `calendar` → `widgets` → `media` → `service_mode`. This determines left-to-right bar layout order.
- **Polling over deprecated events**: `media.lua` polls `nowplaying-cli` every 2s instead of subscribing to `media_change`, which macOS 26 no longer delivers (it also fed the built-in `media.artwork` provider). Artwork is fetched only when the track changes, base64-decoded to `$TMPDIR/sketchybar-artwork-<hash>.png`, and set as `background.image`.
- **Global-state indicator**: `service_mode.lua` tints `/workspace\..*/` via `sbar.set` on AeroSpace's enter/leave events, subscribed through `root` — sketchybar does not dispatch events to items with `drawing = false`, so a dedicated hidden subscriber receives nothing.

## Flow

```
Bar startup (init.lua → sbar.begin_config() block):
  require("items") → items/init.lua
    ├─ items.apple       → sbar.add("item", "apple", …) + bracket + spacer
    ├─ items.workspaces  → sbar.exec("aerospace list-workspaces …") →
    │                      for each workspace: sbar.add("item", "workspace.<name>") + subscribe(aerospace_workspace_change)
    │                      → async callback: updateWindows(), updateWorkspaceMonitor()
    │                      → reorder bar via sbar.exec("sketchybar --reorder apple ... front_app")
    ├─ items.front_app   → sbar.add("item", "front_app", { display="active" })
    │                      ← subscribe(front_app_switched) → set label = env.INFO
    ├─ items.calendar    → sbar.add("item", date/time + bracket + spacer
    │                      ← subscribe(forced|routine|system_woke) → os.date update
    ├─ items.widgets     → items/widgets/init.lua (battery, volume, wifi, cpu)
    ├─ items.media       → now-playing: cover art, artist, title + popup controls
    │                      ← polls nowplaying-cli every 2s; subscribe(mouse.entered/exited/clicked)
    └─ items.service_mode → tints the workspace items while AeroSpace service mode is active
                           ← subscribe(aerospace_enter/leave_service_mode) on `root`
```

**Event-to-Callback Map**:

| Event Source | Subscriber | Action |
|---|---|---|
| `front_app_switched` (built-in) | `front_app` | Set label to front app name |
| `forced`, `routine`, `system_woke` | `calendar` | Update date/time via `os.date` |
| `aerospace_workspace_change` (aerospace) | each workspace item | Highlight focused workspace, update border |
| `aerospace_focus_change` (aerospace) | `root` item | Refresh all window icons |
| `display_change` (built-in) | `root` item | Update workspace→monitor mapping |
| `aerospace_enter_service_mode` / `aerospace_leave_service_mode` (aerospace) | `root` item | Tint/restore workspace item backgrounds |
| `mouse.clicked` | `media_cover` | Toggle popup |
| `mouse.entered` / `mouse.exited` | `media_cover` | Animate detail expand/collapse |
| `mouse.exited.global` | `media_title` | Close media popup |

## Integration

- **Depends on**: `colors.lua`, `icons.lua`, `settings.lua` (shared config), `helpers.app_icons.lua` (icon lookup for workspaces).
- **Consumed by**: sketchybar daemon — items are registered as sketchybar domain objects. The `init.lua` registration is part of the `sbar.begin_config()` / `sbar.end_config()` batch.
- **External triggers**: `aerospace` CLI (workspace queries, window lists), `nowplaying-cli` (media controls), `osascript` (AppleScript exec), `$CONFIG_DIR/helpers/menus/bin/menus` (Apple menu interaction). All external CLIs are invoked by bare name, which works because `programs.sketchybar.extraPackages` puts them on the bar's wrapper-generated `PATH`; a new shell-out needs an `extraPackages` entry.
- **Environment variables**: `$INFO` (set by front_app_switched and volume_change events), `$FOCUSED_WORKSPACE` (set by aerospace_workspace_change event), `$BUTTON` (mouse button), `$NAME` (item name in click_scripts).
