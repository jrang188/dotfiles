# sketchybar/helpers/

## Responsibility

Shared infrastructure layer providing: (1) Lua package path initialization and C binary compilation (`init.lua`, `makefile`), (2) macOS font configuration data (`default_font.lua`), (3) application-icon mapping table (`app_icons.lua`), (4) external event provider daemons written in C (`event_providers/`), and (5) a macOS accessibility-based menu bar helper C binary (`menus/`).

## Design

- **Bootstrap Builder Pattern**: `init.lua` sets the Lua module search path (`package.cpath`) to point at `~/.local/share/sketchybar_lua/` for the SbarLua native `.so`, then synchronously invokes `make` to compile all C binaries under `event_providers/` and `menus/`. This runs exactly once at bar startup.
- **External Event Provider Architecture** (`event_providers/`): Long-running C processes that act as **custom event sources** for the sketchybar event system. Each binary:
  1. Registers a named event with sketchybar via `--add event '<name>'`
  2. Enters a polling loop: reads system metrics → formats a `--trigger` message → sends it to the sketchybar daemon via Mach IPC → sleeps for a configurable interval.
  3. The Mach IPC mechanism is abstracted in `sketchybar.h` using `bootstrap_look_up()` to find sketchybar's port and `mach_msg()` with OOL descriptors to send command strings.
- **Shared Messaging Protocol** (`sketchybar.h`): Provides `sketchybar(char* message)` which tokenizes the string into null-separated arguments (respecting quotes) and sends it as a Mach OOL message — functionally equivalent to calling `sketchybar` CLI from shell but without fork/exec overhead.
- **Menu Bar Interaction** (`menus/menus.c`): A standalone C binary using the macOS Accessibility (Carbon) and SkyLight private frameworks to list and select menu bar items of the frontmost application. Used by `items/apple.lua` to trigger the Apple menu.
- **Application Icon Registry** (`app_icons.lua`): A ~300-entry lookup table mapping macOS application names to `sketchybar-app-font` icon glyph identifiers (e.g., `"Live" → ":ableton:"`). Used by `items/workspaces.lua` for window indicators.

## Flow

```
init.lua (at bar startup):
  1. Set package.cpath for SbarLua .so
  2. os.execute("(cd helpers && make)")
       ├─ event_providers/ → make → builds cpu_load/bin/cpu_load + network_load/bin/network_load
       └─ menus/           → make → builds menus/bin/menus

At item registration time (items/widgets/cpu.lua, items/widgets/wifi.lua):
  sbar.exec("killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0")
  └─ cpu_load binary runs in background:
       └─ --add event 'cpu_update'
       └─ loop: host_statistics() → --trigger 'cpu_update' user_load=… sys_load=… total_load=…
            └─ Mach IPC → sketchybar daemon dispatches to subscribed Lua callbacks

On Apple menu click (items/apple.lua):
  click_script → $CONFIG_DIR/helpers/menus/bin/menus -s 0
  └─ Uses AX API + SkyLight to find front app menu bar, press first item (Apple menu)
```

## Integration

- **Depended on by**: `items/apple.lua` (menus binary), `items/widgets/cpu.lua` (cpu_load binary), `items/widgets/wifi.lua` (network_load binary), `items/workspaces.lua` (app_icons table), `settings.lua` (default_font table).
- **Depends on**: sketchybar daemon (Mach IPC bootstrap port `git.felix.<bar_name>`), macOS system frameworks (Carbon, SkyLight, `mach/mach.h`, `sys/sysctl.h`), Homebrew packages (`lua`, `switchaudio-osx`, `nowplaying-cli`).
- **Build output**: binaries in `event_providers/cpu_load/bin/`, `event_providers/network_load/bin/`, `menus/bin/` — all gitignored via `.gitignore` (`bin/`).
- **Environment variables**: `$BAR_NAME` (used by `sketchybar.h` to look up correct Mach port, defaults to `"sketchybar"`), `$CONFIG_DIR` (used by item scripts to locate binary paths).
