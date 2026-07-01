# sketchybar/

## Responsibility

Top-level configuration root for the sketchybar macOS status bar. Contains the entry-point bootstrap script (`sketchybarrc`), the Lua initialization pipeline (`init.lua`), bar geometry and defaults (`bar.lua`, `default.lua`), and shared constants (`colors.lua`, `icons.lua`, `settings.lua`). This folder owns the **startup lifecycle** and **global appearance defaults** for the bar.

## Design

- **Chained Bootstrap Pipeline**: `sketchybarrc` → `helpers/init.lua` (cpath + C build) → `init.lua` (SbarLua init, config batching, event loop). Each step sets up infrastructure for the next.
- **Batch Configuration** (`sbar.begin_config()` / `sbar.end_config()`): All domain definitions (bar, defaults, items) are queued into a single Mach IPC message, reducing startup IPC round-trips. This is a **deferred execution** / **command-batching** pattern.
- **SbarLua Integration**: The `sketchybar` Lua module (SbarLua via `require("sketchybar")`) provides the Lua-to-Mach-IPC bridge. The global `sbar` handle is the sole API surface for all bar/item/event interactions.
- **Singleton Color & Icon Stores**: `colors.lua` and `icons.lua` are pure data modules returning shared tables. `icons.lua` selects between `sf_symbols` and `nerdfont` icon sets based on `settings.icons`, implementing a **strategy pattern** at module resolution time.
- **Theme via `default.lua`**: All item defaults (fonts, colors, background geometry, popup styling) are set once via `sbar.default({...})`, equivalent to the `--default` sketchybar CLI domain. Individual items override only what differs.
- **Event Loop Required**: `sbar.event_loop()` must be the final call in `init.lua` — it enters a Mach message receive loop. Without it, no Lua callbacks (subscriptions) execute.

## Flow

```
sketchybarrc
  └─ require("helpers")        → sets package.cpath, runs `make` to compile C binaries
  └─ require("init")
       └─ sbar = require("sketchybar")   → SbarLua loads native .so
       └─ sbar.begin_config()            → open batch message
       └─ require("bar")                 → sbar.bar({…}) — bar geometry/color
       └─ require("default")             → sbar.default({…}) — item style defaults
       └─ require("items")               → items/init.lua registers all items/widgets
       └─ sbar.end_config()              → flush batch to sketchybar daemon via Mach IPC
       └─ sbar.event_loop()              → enter Mach receive loop (blocking)
```

`C binaries (cpu_load, network_load)` are launched asynchronously by widget scripts (via `sbar.exec("killall ...; $CONFIG_DIR/helpers/event_providers/...")`). They poll system metrics and send `--trigger` messages to the sketchybar daemon via the same Mach IPC protocol, which dispatches them as events to subscribed Lua callbacks.

## Integration

- **Consumed by**: Items under `items/` and `items/widgets/` via `require("colors")`, `require("icons")`, `require("settings")`.
- **Depends on**: `helpers/init.lua` (cpath + C build), SbarLua (`sketchybar.so`), sketchybar daemon (Mach IPC bootstrap service).
- **API surface**: Global `sbar` object with methods `bar()`, `default()`, `add()`, `begin_config()`, `end_config()`, `event_loop()`, `exec()`, `animate()`, `delay()`, `trigger()`, `remove()`, `set()`, `query()`.
- **Environment variables**: `$CONFIG_DIR` (set by sketchybar to this directory), `$NAME` (set per-item during click_scripts), `$USER` (used by helpers/init.lua for cpath).
