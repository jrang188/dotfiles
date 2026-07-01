# sketchybar/items/

## Responsibility

Bar item definition and registration. Each Lua module in this directory declares one or more sketchybar items (including brackets, popups, spacers) and wires their event subscriptions. This is the primary **UI component layer** — it translates system events into visible bar state changes.

## Design

- **Declarative Item Registration**: Each file calls `sbar.add(type, name?, config)` to create items. Types used: `"item"` (text/icon), `"bracket"` (visual grouping with shared background), and graph/popup variants. Items are positioned either on the bar or inside a popup via `position = "popup.<parent_name>"`.
- **Observer Pattern via Event Subscriptions**: Items subscribe to sketchybar events using `item:subscribe(event_names, callback)`. The sketchybar daemon delivers events asynchronously via Mach IPC; callbacks receive an `env` table with event-specific keys. Multiple items can subscribe to the same event.
- **Bracket Wrapping for Borders**: Several items (`apple.lua`, `calendar.lua`) use a bracket containing a single item to achieve a **double-border** visual effect — the bracket provides an outer border, the item provides an inner border.
- **Padding Items for Layout**: Spacer items (zero-width or fixed-width) are inserted before/after bracketed groups to maintain consistent spacing. This is a consequence of brackets consuming their children's outer margins.
- **Orchestrated Registration**: `items/init.lua` requires modules in order: `apple` → `workspaces` → `front_app` → `calendar` → `widgets` → `media`. This determines left-to-right bar layout order.

## Flow

```
Bar startup (init.lua → sbar.begin_config() block):
  require("items") → items/init.lua
    ├─ items.apple       → sbar.add("item"), apple icon + bracket + spacer
    ├─ items.workspaces  → sbar.exec to query aerospace workspaces →
    │                      for each workspace: sbar.add("item") + subscribe(aerospace_workspace_change)
    │                      → async callback: updateWindows(), updateWorkspaceMonitor()
    │                      → reorder bar via sbar.exec("sketchybar --reorder apple ... front_app")
    ├─ items.front_app   → sbar.add("item", "front_app", { display="active" })
    │                      ← subscribe(front_app_switched) → set label = env.INFO
    ├─ items.calendar    → sbar.add("item", date/time + bracket + spacer
    │                      ← subscribe(forced|routine|system_woke) → os.date update
    ├─ items.widgets     → items/widgets/init.lua (battery, volume, wifi, cpu)
    └─ items.media       → now-playing: cover art, artist, title + popup controls
                           ← subscribe(media_change, mouse.entered/exited/clicked)
```

**Event-to-Callback Map**:

| Event Source | Subscriber | Action |
|---|---|---|
| `front_app_switched` (built-in) | `front_app` | Set label to front app name |
| `forced`, `routine`, `system_woke` | `calendar` | Update date/time via `os.date` |
| `aerospace_workspace_change` (aerospace) | each workspace item | Highlight focused workspace, update border |
| `aerospace_focus_change` (aerospace) | `root` item | Refresh all window icons |
| `display_change` (built-in) | `root` item | Update workspace→monitor mapping |
| `media_change` (built-in) | `media_cover` | Show/hide media artwork, artist, title |
| `mouse.clicked` | `front_app`, `media_cover` | Swap menus & spaces / toggle popup |
| `mouse.entered` / `mouse.exited` | `media_cover` | Animate detail expand/collapse |
| `mouse.exited.global` | `media_title` | Close media popup |

## Integration

- **Depends on**: `colors.lua`, `icons.lua`, `settings.lua` (shared config), `helpers.app_icons.lua` (icon lookup for workspaces).
- **Consumed by**: sketchybar daemon — items are registered as sketchybar domain objects. The `init.lua` registration is part of the `sbar.begin_config()` / `sbar.end_config()` batch.
- **External triggers**: `aerospace` CLI (workspace queries, window lists), `nowplaying-cli` (media controls), `osascript` (AppleScript exec), `$CONFIG_DIR/helpers/menus/bin/menus` (Apple menu interaction).
- **Environment variables**: `$INFO` (set by front_app_switched and volume_change events), `$FOCUSED_WORKSPACE` (set by aerospace_workspace_change event), `$BUTTON` (mouse button), `$NAME` (item name in click_scripts).
