-- Add the sketchybar module to the package cpath.
--
-- Legacy fallback only: Home Manager's wrapper supplies LUA_CPATH pointing at
-- the Nix-built SbarLua module, which is searched first. This path holds a copy
-- hand-built by the old `brew services` setup, and must not assume a hardcoded
-- home-directory layout.
package.cpath = package.cpath .. ";" .. (os.getenv("HOME") or "") .. "/.local/share/sketchybar_lua/?.so"

-- Build the C helpers (cpu_load, network_load, menus). `-s` suppresses make's
-- recipe echoes (which otherwise land in the bar's log on every start) and
-- stdout is dropped, while compiler diagnostics stay on stderr where they are
-- visible. In Lua 5.2+ os.execute returns true on success, so a broken build is
-- reported instead of failing silently.
local built = os.execute("(cd helpers && make -s >/dev/null)")
if not built then
  io.stderr:write("[sketchybar] helpers build failed: cpu/network widgets and the Apple menu will not work\n")
end
