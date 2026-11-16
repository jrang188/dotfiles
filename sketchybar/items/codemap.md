# sketchybar/items/

## Responsibility

Bar item definition and registration. Each Lua module in this directory declares one or more sketchybar items (including brackets, popups, spacers) and wires their event subscriptions. This is the primary **UI component layer** — it translates system events into visible bar state changes.

## Design

- **Declarative Item Registration**: Each file calls `sbar.add(type, name, config)` to create items. Types used: `"item"` (text/icon), `"bracket"` (visual grouping with shared background), `"graph"` (`widgets.cpu`) and `"slider"` (`widgets.volume.popup.slider`). Every `sbar.add` passes an explicit name — nothing falls back to sketchybar's auto-generated `item_%d`, so `--reorder`, `sbar.set`/`sbar.remove` regexes and `$NAME` all stay stable. Items are positioned either on the bar or inside a popup via `position = "popup.<parent_name>"`.
- **Observer Pattern via Event Subscriptions**: Items subscribe to sketchybar events using `item:subscribe(event_names, callback)`. The sketchybar daemon delivers events asynchronously via Mach IPC; callbacks receive an `env` table with event-specific keys. Multiple items can subscribe to the same event.
- **Bracket Wrapping for Borders**: Several items (`apple.lua`, `calendar.lua`) use a bracket containing a single item to achieve a **double-border** visual effect — the bracket provides an outer border, the item provides an inner border.
- **Padding Items for Layout**: Spacer items (zero-width or fixed-width) are inserted before/after bracketed groups to maintain consistent spacing. This is a consequence of brackets consuming their children's outer margins.
- **Orchestrated Registration**: `items/init.lua` requires modules in order: `apple` → `workspaces` → `front_app` → `calendar` → `widgets` → `media` → `service_mode`. This determines left-to-right bar layout order.
- **Polling over deprecated events**: `media.lua` polls `media-control` every 2s instead of subscribing to `media_change`, which macOS 26 no longer delivers (it also fed the built-in `media.artwork` provider). `nowplaying-cli` is NOT usable here — it returns `null` for every key on macOS 26. The poll strips the 100 KB `artworkData` field in the shell (470 bytes remain) and SbarLua decodes the JSON into a table; artwork is re-fetched only when `contentItemIdentifier` changes, named from a djb2 hash of that key in `$TMPDIR` (a fixed filename would serve a cached image), normalised to 56px with `sips`, and drawn at `scale = 0.5`. `scale` multiplies the image's natural size, so an un-normalised 600px cover draws ~510px wide across the bar. A `bundleIdentifier` whitelist (Spotify, Apple Music) plus a playing check gate visibility, and the first poll is deferred 1s so it cannot race the `begin_config`/`end_config` batch.
- **Global-state indicator**: `service_mode.lua` sets `/workspace\..*/` `background.color` to `colors.orange` (back to `colors.bg1` on leave) on AeroSpace's enter/leave events, subscribed through `root` — sketchybar does not dispatch events to items with `drawing = false`, so a dedicated hidden subscriber receives nothing. The tint is safe because the focus handlers only touch `border_width`, `label` and `icon`.

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
    ├─ items.calendar    → sbar.add("item", "calendar", …) + bracket + spacer
    │                      ← subscribe(forced|routine|system_woke) → os.date update
    ├─ items.widgets     → items/widgets/init.lua (battery, volume, wifi, cpu)
    ├─ items.media       → now-playing: cover art, artist, title + popup controls
    │                      ← polls media-control every 2s; subscribe(mouse.entered/exited/clicked)
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
- **External triggers**: `aerospace` CLI (workspace queries/focus, window lists — from `extraPackages`), `media-control` (media metadata, artwork source and transport — a Homebrew formula reached through the wrapper's hardcoded `/opt/homebrew/bin`), `open -a` (Calendar, Activity Monitor), `$CONFIG_DIR/helpers/menus/bin/menus` (Apple menu interaction), and shell text tools for the media poll (`plutil`, `base64`, `sed`, `sips`). All are invoked by bare name: the wrapper's `PATH` is `programs.sketchybar.extraPackages` plus the system directories and `/opt/homebrew/bin`, never the rest of the Nix profile — so a Nix-provided CLI needs an `extraPackages` entry, while Homebrew/system tools do not.
- **Environment variables**: `$INFO` (set by front_app_switched and volume_change events), `$FOCUSED_WORKSPACE` (set by aerospace_workspace_change event), `$BUTTON` (mouse button), `$NAME` (item name in click_scripts).
