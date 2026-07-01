# sketchybar/items/widgets/

## Responsibility

Right-aligned status bar widgets providing system-level information: battery state, CPU usage graph, audio volume control, and Wi-Fi/network throughput. Each widget is an autonomous module that owns its item lifecycle — registration, event subscription, popup construction, and bracket styling.

## Design

- **Provider-Consumer Event Pattern**: Widgets that require periodic polling (CPU, network) launch external C event-provider daemons from `helpers/event_providers/` via `sbar.exec()`. These daemons run independently, sending `--trigger` messages to sketchybar. Widgets subscribe to the triggered events and update their state reactively — a **push-based** architecture decoupling data acquisition from UI rendering.
- **Self-Contained Widget Modules**: Each `.lua` file is fully independent — it registers its items, brackets, spacers, popup children, and all event subscriptions. The module loads its dependencies (`colors`, `icons`, `settings`) at the top. This is a **component pattern** analogous to a React component owning its subtree.
- **Bracket Grouping**: Each widget wraps its item(s) in a `sbar.add("bracket", ...)` with a shared `background.color = colors.bg1`. Trailing spacer items (`settings.group_paddings` wide) maintain consistent gap between widget groups.
- **Popup Details Pattern**: Battery, volume, and Wi-Fi use click-toggled popups (`.popup = { drawing = "toggle" }`) that reveal secondary information: estimated time remaining, audio device switcher with slider, and network diagnostics (SSID, IP, subnet, router). Popup items use `position = "popup.<bracket_name>"` to nest inside their parent bracket.
- **Mouse Event Wiring**: Widgets handle `mouse.clicked` (toggle details, open prefs), `mouse.scrolled` (volume ±), `mouse.entered`/`mouse.exited` (media detail animation), and `mouse.exited.global` (close popup on click-away). This is a **direct-manipulation** interaction model.

## Flow

```
Startup (items/init.lua → require("items.widgets")):
  widgets/init.lua
    ├─ battery.lua
    │   ├─ sbar.add("item", "widgets.battery", { position="right", update_freq=180 })
    │   ├─ sbar.add("item", popup.battery — time remaining label)
    │   ├─ subscribe(routine|power_source_change|system_woke)
    │   │   └─ sbar.exec("pmset -g batt") → parse % and AC power → set icon/label/color
    │   ├─ subscribe(mouse.clicked)
    │   │   └─ toggle popup → exec pmset for remaining time
    │   └─ bracket + padding spacer
    │
    ├─ volume.lua
    │   ├─ sbar.add("item", percent + icon, { position="right" })
    │   ├─ sbar.add("bracket", grouping icon+percent, { popup.align="center" })
    │   ├─ subscribe(volume_change)
    │   │   └─ update icon (0/33/66/100), percent label, slider percentage
    │   ├─ subscribe(mouse.scrolled on icon|percent)
    │   │   └─ osascript volume ± delta
    │   ├─ subscribe(mouse.clicked on icon|percent)
    │   │   └─ toggle popup → SwitchAudioSource -a -t output → list devices
    │   ├─ subscribe(mouse.exited.global)
    │   │   └─ collapse popup, remove device items
    │   ├─ sbar.add("slider", popup.bracket — volume slider)
    │   └─ padding spacer
    │
    ├─ wifi.lua
    │   ├─ sbar.exec("killall network_load; …/network_load en0 network_update 2.0")
    │   ├─ sbar.add("item", upload speed + download speed + wifi icon)
    │   ├─ sbar.add("bracket", { wifi, wifi_up, wifi_down }, popup config)
    │   ├─ subscribe(network_update on wifi_up/wifi_down)
    │   │   └─ set upload/download label + color (grey if idle)
    │   ├─ subscribe(wifi_change|system_woke on wifi)
    │   │   └─ ipconfig → connected/disconnected icon
    │   ├─ mouse.clicked on wifi* → toggle popup →
    │   │   └─ sbar.exec → populate SSID, hostname, IP, subnet, router labels
    │   ├─ mouse.exited.global → hide popup
    │   ├─ mouse.clicked on info items → copy label to clipboard via pbcopy
    │   └─ padding spacer
    │
    └─ cpu.lua
        ├─ sbar.exec("killall cpu_load; …/cpu_load cpu_update 2.0")
        ├─ sbar.add("graph", "widgets.cpu", 42, { position="right" })
        │   — 42-wide graph with blue/yellow/orange/red threshold coloring
        ├─ subscribe(cpu_update)
        │   └─ cpu:push(load/100), set graph.color + label string
        ├─ subscribe(mouse.clicked) → open Activity Monitor
        └─ bracket + padding spacer
```

## Integration

- **Depends on**: `colors.lua` (threshold-based color selection: green→orange→red for battery, blue→yellow→orange→red for CPU), `icons.lua` (battery, volume, Wi-Fi SF Symbols/NerdFont), `settings.lua` (font families, paddings).
- **External binaries**: `pmset` (battery info), `SwitchAudioSource` (audio device listing), `nowplaying-cli` (used by media.lua, not widgets directly), `ipconfig`/`networksetup` (network info), `osascript` (volume control), `pbcopy` (clipboard).
- **Event providers** (launched as sidecar processes): `helpers/event_providers/cpu_load/bin/cpu_load` (publishes `cpu_update`), `helpers/event_providers/network_load/bin/network_load en0` (publishes `network_update`).
- **Built-in events subscribed**: `routine`, `power_source_change`, `system_woke`, `wifi_change`, `volume_change`, `mouse.clicked`, `mouse.scrolled`, `mouse.entered`, `mouse.exited`, `mouse.exited.global`.
- **Item naming convention**: Widget items follow `widgets.<name>[N]` pattern (e.g., `widgets.battery`, `widgets.cpu`, `widgets.volume1`, `widgets.volume2`) enabling targeted `sbar.remove()` and `sbar.set()` calls by pattern.
