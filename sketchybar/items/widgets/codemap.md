# sketchybar/items/widgets/

## Responsibility

Right-aligned status bar widgets providing system-level information: battery state, CPU usage graph, audio volume control, and Wi-Fi/network throughput. Each widget is an autonomous module that owns its item lifecycle — registration, event subscription, popup construction, and bracket styling.

## Design

- **Provider-Consumer Event Pattern**: Widgets that require periodic polling (CPU, network) launch external C event-provider daemons from `helpers/event_providers/` via `sbar.exec()`. These daemons run independently, sending `--trigger` messages to sketchybar. Widgets subscribe to the triggered events and update their state reactively — a **push-based** architecture decoupling data acquisition from UI rendering.
- **Self-Contained Widget Modules**: Each `.lua` file is fully independent — it registers its items, brackets, spacers, popup children, and all event subscriptions. The module loads its dependencies (`colors`, `icons`, `settings`) at the top. This is a **component pattern** analogous to a React component owning its subtree.
- **Bracket Grouping**: Each widget wraps its item(s) in a `sbar.add("bracket", ...)` with a shared `background.color = colors.bg1`. Trailing spacer items (`settings.group_paddings` wide) maintain consistent gap between widget groups.
- **Popup Details Pattern**: Battery, volume, and Wi-Fi use click-toggled popups that reveal secondary information: estimated time remaining, audio device switcher with slider, and network diagnostics (SSID, hostname, IP, subnet, router). Battery replies with `popup.drawing = "toggle"` and only queries `pmset` for the estimate when it was off; volume and Wi-Fi compute the next state from `bracket:query().popup.drawing`. Popup items use `position = "popup.<parent_name>"` — the bracket for volume and Wi-Fi (`widgets.volume.bracket`, `widgets.wifi.bracket`), but the item itself for battery (`popup.widgets.battery`), since that item carries its own `popup` config.
- **Mouse Event Wiring**: Widgets handle `mouse.clicked` (toggle details, open prefs), `mouse.scrolled` (volume ±), and `mouse.exited.global` (close popup on click-away). This is a **direct-manipulation** interaction model.

## Flow

```
Startup (items/init.lua → require("items.widgets")):
  widgets/init.lua
    ├─ battery.lua
    │   ├─ sbar.add("item", "widgets.battery", { position="right", update_freq=180 })
    │   ├─ sbar.add("item", "widgets.battery.popup.time_remaining")
    │   ├─ subscribe(routine|power_source_change|system_woke)
    │   │   └─ sbar.exec("pmset -g batt") → parse % and AC power → set icon/label/color
    │   ├─ subscribe(mouse.clicked)
    │   │   └─ toggle popup → exec pmset for remaining time
    │   └─ bracket + padding spacer
    │
    ├─ volume.lua
    │   ├─ sbar.add("item", "widgets.volume1" (percent) / "widgets.volume2" (icon), { position="right" })
    │   ├─ sbar.add("bracket", "widgets.volume.bracket", { icon, percent }, { popup.align="center" })
    │   ├─ subscribe(volume_change)
    │   │   └─ update icon (0/10/33/66/100 thresholds), percent label, slider percentage
    │   ├─ subscribe(mouse.scrolled on icon|percent)
    │   │   └─ osascript volume ± delta (delta ×10 unless the ctrl modifier is held)
    │   ├─ subscribe(mouse.clicked on icon|percent)
    │   │   └─ right button → open Sound.prefpane; left → toggle popup →
    │   │      SwitchAudioSource -t output -c / -a -t output → list devices
    │   ├─ subscribe(mouse.exited.global)
    │   │   └─ collapse popup, remove device items
    │   ├─ sbar.add("slider", "widgets.volume.popup.slider", popup_width, { position="popup.bracket" })
    │   └─ padding spacer
    │
    ├─ wifi.lua
    │   ├─ sbar.exec("killall network_load; …/network_load en0 network_update 2.0")
    │   ├─ sbar.add("item", "widgets.wifi1" / "widgets.wifi2" (speed up/down) + "widgets.wifi.padding" (wifi icon))
    │   ├─ sbar.add("bracket", "widgets.wifi.bracket", { wifi, wifi_up, wifi_down }, popup config)
    │   ├─ subscribe(network_update on wifi_up/wifi_down)
    │   │   └─ set upload/download label + color (grey if idle)
    │   ├─ subscribe(system_woke on wifi)
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
- **External binaries**: `pmset` (battery info), `SwitchAudioSource` (audio device listing/switching, from `switchaudio-osx` in `extraPackages`), `ipconfig`/`networksetup` (network info), `osascript` (volume control), `pbcopy` (clipboard); `sips`/`plutil`/`base64` belong to the media poll, not to these widgets. All are invoked by bare name, which works because the wrapper's `PATH` is `extraPackages` plus the system directories and `/opt/homebrew/bin`.
- **Event providers** (launched as sidecar processes): `helpers/event_providers/cpu_load/bin/cpu_load` (publishes `cpu_update`), `helpers/event_providers/network_load/bin/network_load en0` (publishes `network_update`).
- **Built-in events subscribed**: `routine`, `power_source_change`, `system_woke`, `volume_change`, `mouse.clicked`, `mouse.scrolled`, `mouse.exited.global`.
- **Item naming convention**: every `sbar.add` passes an explicit name, so nothing falls back to sketchybar's auto-generated `item_%d`. Brackets use `widgets.<name>.bracket`, spacers `widgets.<name>.padding` / `.padding_right`, and popup children `widgets.<name>.popup.<role>` (e.g. `widgets.wifi.popup.ssid`, `widgets.volume.popup.slider`, `widgets.battery.popup.time_remaining`). Volume and Wi-Fi split their main row across numbered items (`widgets.volume1`/`widgets.volume2`, `widgets.wifi1`/`widgets.wifi2`, plus `widgets.wifi.padding` holding the Wi-Fi icon), and the runtime-built audio device rows are `volume.device.<n>`. Explicit names keep `sbar.remove()`/`sbar.set()` targeting reliable — the volume popup removes its device rows with the regex `/volume.device\.*/`, and the bar is reordered by name (`--reorder apple <workspaces> front_app`).
