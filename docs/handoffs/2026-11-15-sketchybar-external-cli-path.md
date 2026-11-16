# sketchybar: workspace items vanished after AeroSpace moved to Nix (PATH class bug)

**Date:** 2026-11-15
**Host:** Sterling-MBP (Darwin, aarch64)
**Commits:** regression `a8ddd45`, fix `cffdba8` (HEAD)
**Status:** fixed and verified on the live bar. One out-of-repo cleanup (font) is not tracked by git. Seven backlog items remain open (below).

## Summary

`a8ddd45` replaced the AeroSpace Homebrew cask with the `programs.aerospace` Home Manager module. That moved the `aerospace` CLI from `/opt/homebrew/bin` (on the bar's `PATH`) to `/etc/profiles/per-user/sirwayne/bin` (not on it), so every `sbar.exec("aerospace …")` in `sketchybar/items/workspaces.lua` returned `sh: aerospace: command not found` (exit 127). The workspace items are *created* from that first query, so the creation loop iterated zero times — no numbers, no per-workspace app icons, and no subscriptions. The rest of the bar was unaffected because it does not shell out.

Fix: `sketchybar/helpers/cli.lua` resolves external CLIs to absolute paths, applied at every shell-out site, plus the latent bugs the empty item list had been hiding.

## Symptom

After switching, the bar rendered but the workspace segment was gone: no workspace numbers and no per-workspace app-icon labels. Nothing else visibly changed — the volume, calendar, cpu/network graphs and front-app widgets all kept working.

## Root cause

sketchybar is not Nix-managed. It is the Homebrew formula `felixkratz/formulae/sketchybar` (`nix/hosts/darwin/Sterling-MBP/homebrew.nix:24`), started by `brew services` via `~/Library/LaunchAgents/homebrew.mxcl.sketchybar.plist`, whose environment is hard-coded:

```
EnvironmentVariables.PATH = /opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin
```

Confirmed live:

```sh
ps -Eww -o pid,command -p $(pgrep -x sketchybar)
# PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin

which -a aerospace        # only /etc/profiles/per-user/sirwayne/bin/aerospace
```

The cask used to place a symlink at `/opt/homebrew/bin/aerospace`; Nix does not. The Lua side used bare names (`"aerospace list-workspaces …"`), which `sbar.exec` runs through `/bin/sh` with the inherited environment.

## Failure chain

Why the symptom looked *partial* (bar fine, one segment missing):

1. `sbar.exec(query_workspaces)` fails, so the `ipairs` loop that creates the `workspace.*` items (`sketchybar/items/workspaces.lua:173`) iterates zero times → no items at all.
2. That loop is also where each item subscribes to `aerospace_workspace_change` (`workspaces.lua:209`), so the subscription never registered either. Proof: `sketchybar --query events` listed `aerospace_focus_change` (subscribed later at `workspaces.lua:232`, outside the loop) but **not** `aerospace_workspace_change`.
3. The focused-workspace lookup then indexed an empty table: `workspaces[""]` → `[!] Lua: ./items/workspaces.lua:235: attempt to index a nil value (field '?')` — 874 occurrences in `/opt/homebrew/var/log/sketchybar/sketchybar.out.log` (line 235 is pre-fix numbering; the guarded lookup is now `workspaces.lua:241-252`).
4. Independently, `sbar.exec("sketchybar --reorder apple <workspaces> front_app")` (`workspaces.lua:254`) always failed with `[!] Order: Item 'apple' not found` — 130 occurrences — because `apple` and the workspace items were created anonymously and SbarLua auto-names those `item_%d`.
5. The AeroSpace → sketchybar direction kept working: the triggers in `nix/home/darwin/aerospace.nix:150-158` reached the bar (proven by the focus border tracking workspace changes). See "Corrections" for the one failing half of that command.

## What changed (`cffdba8`)

| File | Change |
| --- | --- |
| `sketchybar/helpers/cli.lua` | **New.** `resolve(name)` probes `/etc/profiles/per-user/$USER/bin`, `~/.nix-profile/bin`, `/run/current-system/sw/bin`, `/opt/homebrew/bin`, `/usr/local/bin` (via `io.open`) and returns the first hit, else the bare name. Nix profiles before Homebrew by design. |
| `sketchybar/items/workspaces.lua` | `local aerospace = cli.resolve("aerospace")` used at all 6 call sites including `click_script` (`:204`); items named `workspace.<name>` (`:177`); whitespace/newline trim on `aerospace list-workspaces --focused` (`:58`, `:242`); nil guard on the focused lookup (`:243-246`); `colors.bg0` → `colors.bg1` (`:26`; `colors.lua` only defines `bg1`/`bg2`). |
| `sketchybar/items/apple.lua` | Item named `"apple"`, so `--reorder apple … front_app` resolves. |
| `sketchybar/items/media.lua` | `nowplaying-cli` resolved for the three transport `click_script`s (21× not-found; the popup controls were dead). |
| `sketchybar/items/widgets/volume.lua` | `SwitchAudioSource` **and** `sketchybar` resolved (used in the device `click_script`); the audio-device popup was empty (12× not-found). Also removed a dead outer `local color` (shadowed by the per-device local at `:124`) and confined the leaked global `current` with `local`. |
| `sketchybar/items/front_app.lua` | Removed the dead `mouse.clicked` → `sbar.trigger("swap_menus_and_spaces")`; this config never requires `items/menus.lua` (the file does not exist), so the event was never registered. |
| `sketchybar/helpers/app_icons.lua` | `:pdf:` → `:preview:` for Preview/Skim/zathura/预览/Aperçu — renamed in sketchybar-app-font 3.0.20. |
| `sketchybar/helpers/codemap.md`, `sketchybar/items/codemap.md` | Document `cli.lua` and the rule: **every external CLI must go through `helpers.cli.resolve()`**. |

## Verification (acceptance test)

```sh
sketchybar --query bar | grep -c '"workspace\.'          # 16
sketchybar --query workspace.1                            # label value " :ghostty: :zen_browser:"
sketchybar --query events | grep aerospace                # both aerospace_workspace_change and _focus_change
/etc/profiles/per-user/sirwayne/bin/aerospace workspace 2 # focus border: ws1 2→1, ws2 1→2
sketchybar --trigger mouse.clicked SENDER=widgets.volume1 NAME=widgets.volume1 BUTTON=left
sketchybar --query bar | grep -c 'volume\.device'         # 3 (items are created on demand, so 0 after a restart)
```

Restart (`killall sketchybar`; launchd `KeepAlive` respawns it) then compare log counts — the logs are append-only and full of pre-2025 history, so never tail them:

```sh
cd /opt/homebrew/var/log/sketchybar
grep -c "command not found" sketchybar.err.log                      # 284, unchanged
grep -c "Order: Item" sketchybar.err.log                            # 130, unchanged
grep -c "nowplaying-cli: command not found" sketchybar.err.log      # 21, unchanged
grep -c "SwitchAudioSource: command not found" sketchybar.err.log   # 12, unchanged
grep -c "attempt to index a nil value" sketchybar.out.log           # 874, unchanged
```

## Out-of-repo change (not in git)

`~/Library/Fonts/sketchybar-app-font.ttf` was v2.0.5 (253 KB, downloaded by `sketchybar/helpers/install.sh:14`) and **shadowed Nix's v3.0.20 under the same family name**, so the `:preview:` rename was unreliable. It was moved to `$TMPDIR/opencode/sketchybar-app-font-v2.0.5.ttf.bak` (253,532 bytes). `system_profiler SPFontsDataType` now reports a single entry, `/Library/Fonts/Nix Fonts/…-sketchybar-app-font-3.0.20/…/sketchybar-app-font.ttf`, `Version 3.0.20`, `Duplicate: No`. The font itself comes from `nix/modules/darwin/system.nix:34`. The fix is reproducible nowhere else — a fresh `install.sh` run would re-introduce the shadowing.

## Corrections to the session's initial assumptions

- **AeroSpace → sketchybar is only *half* working.** `/tmp/aerospace.err.log` contains 4× `/bin/bash: aerospace: command not found`, all from the `exec-on-workspace-change` command (`aerospace.nix:150-154`): its `$(aerospace list-monitors --focused | awk …)` runs in AeroSpace's own exec shell, which does not have the Nix profile either. `FOCUSED_DISPLAY` therefore arrives empty. It is invisible because nothing in the Lua config reads `FOCUSED_DISPLAY` (grep: no hits). Backlog item 1 addresses this.
- Line numbers cited in the commit message (235, 245) are pre-fix. Post-fix: focused lookup `workspaces.lua:241-252`, `aerospace_focus_change` subscription `:232`.
- The trim is `:match("^%s*(.-)%s*$")` — it strips all surrounding whitespace, not just the trailing newline.

## Open backlog (not implemented, prioritized)

1. **Root-cause the PATH class instead of patching per command.** nixpkgs already ships sketchybar 2.24.1 (`nix eval --raw .#darwinConfigurations.Sterling-MBP.pkgs.sketchybar.version`), so the bar could move from the brew formula + `brew services` to a nix-darwin / Home Manager `launchd.user.agents` entry with an explicit `EnvironmentVariables.PATH` including the Nix profile. Pair it with `exec.env-vars.PATH` in `nix/home/darwin/aerospace.nix` (no such block exists today) so `sketchybar --trigger` and the `aerospace list-monitors` subshell stop depending on AeroSpace's inherited launchd `PATH`. Retire `helpers/cli.lua` afterwards.
2. **Upstream event deprecations.** Per upstream sketchybar docs consulted during the session: `wifi_change` is documented as not working since macOS Sonoma (`items/widgets/wifi.lua:176` subscribes to it, alongside `system_woke`) and `media_change` is documented as deprecated on macOS 26.0 (Tahoe, which this host runs) — `items/media.lua` relies on it for artwork/artist/title. Traffic graphs are unaffected (C `network_load` provider). *Not re-verified in this pass.*
3. **Stale install docs.** `sketchybar/helpers/install.sh` and the byte-identical `helpers/install` reference the retired `homebrew/cask-fonts` tap, re-download font v2.0.5 (see above), and brew-install `lua`, `switchaudio-osx`, `nowplaying-cli` — all of which Nix now provides. Delete, or shrink to the SbarLua `.so` bootstrap.
4. **SbarLua maintenance risk.** `~/.local/share/sketchybar_lua/sketchybar.so` (288 KB, built 2026-03-07) statically links Lua 5.5.0 (`strings` shows `$LuaVersion: Lua 5.5.0`), while brew ships `lua 5.5.1`. No version guard: a future `brew upgrade lua` to 5.6 breaks the bar with no diagnostic. Upstream SbarLua has been unmaintained since 2026-03-06, and nothing under `nix/` builds the `.so`.
5. **Dead config.** `nix/home/zsh.nix:39` fires `sketchybar --trigger brew_update` from a `brew()` wrapper, but nothing subscribes to `brew_update` (no subscription exists anywhere in `sketchybar/`).
6. **Log hygiene.** ~26,182 lines of `[?] Regex: No match found for regex '/volume.device\.*/'` — `items/widgets/volume.lua` removes the popup items whether or not any exist; `killall cpu_load/network_load` noise; `helpers/init.lua:4` runs `os.execute("(cd helpers && make)")` on load (blocking, requires Xcode CLT, relative path assumes cwd is `$CONFIG_DIR`, spews compiler output into the log), and `init.lua:2` hardcodes `/Users/` + `$USER` in `package.cpath`.
7. **Aesthetic / latent.** Most remaining items are still anonymous `item_N` (only `root`, `apple`, `workspace.*`, `front_app`, `volume.device.*` are named). Workspace items are pinned with `display = …` and all carry `associated_display_mask=2` with one display attached. `items/widgets/wifi.lua` interpolates the SSID unescaped into `echo "…" | pbcopy`.

## Debugging recipe

```sh
# 1. The bar's real environment (launchd-inherited, tiny):
ps -Eww -o pid,command -p $(pgrep -x sketchybar)

# 2. Reproduce a failure in exactly that environment:
env -i PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin \
  /bin/sh -c 'aerospace list-workspaces --all'

# 3. Which events actually registered (a missing event = its registration code never ran):
sketchybar --query events

# 4. What items exist:
sketchybar --query bar
sketchybar --query workspace.1

# 5. Logs — APPEND-ONLY with months of history: always diff counts before/after, never tail.
ls -l /opt/homebrew/var/log/sketchybar/sketchybar.{out,err}.log
# Lua errors and stdout go to out.log; stderr (incl. "command not found") to err.log.
# AeroSpace's own logs: /tmp/aerospace.log (empty) and /tmp/aerospace.err.log.
```

Restart with `killall sketchybar` — do not `brew services restart`, and do not run `sketchybar` manually (the plist's `KeepAlive` already respawns it; a second instance prints `could not acquire lock-file… already running?`).

## Related files / commits

- `a8ddd45` — feat (darwin): manage aerospace through home-manager (regression commit; deleted `aerospace/aerospace.toml`, added `nix/home/darwin/aerospace.nix`)
- `cffdba8` — fix (sketchybar): resolve external CLIs by absolute path (this fix)
- `nix/home/darwin/aerospace.nix` — generated `~/.aerospace.toml`; `after-startup-command` (l.145) also launches `sketchybar` and `borders`; `exec-on-workspace-change` / `on-focus-changed` (l.150-158) trigger the card events
- `nix/hosts/darwin/Sterling-MBP/homebrew.nix:24` — the brew sketchybar formula (plus `sf-symbols` font)
- `nix/modules/darwin/system.nix:34` — `fonts.packages = [ sketchybar-app-font ]` (3.0.20 source of truth)
- `sketchybar/helpers/cli.lua`, `sketchybar/items/workspaces.lua`, `sketchybar/items/apple.lua`, `sketchybar/items/media.lua`, `sketchybar/items/widgets/volume.lua`, `sketchybar/items/front_app.lua`, `sketchybar/helpers/app_icons.lua`
- `sketchybar/codemap.md`, `sketchybar/helpers/codemap.md`, `sketchybar/items/codemap.md` — read these first; `~/.config/sketchybar` is a stow symlink to `sketchybar/`
- `/opt/homebrew/var/log/sketchybar/sketchybar.{out,err}.log`, `/tmp/aerospace.{log,err}.log`
