-- Build the C helpers (cpu_load, network_load, menus). `-s` suppresses make's
-- recipe echoes (which otherwise land in the bar's log on every start) and
-- stdout is dropped, while compiler diagnostics stay on stderr where they are
-- visible. In Lua 5.2+ os.execute returns true on success, so a broken build is
-- reported instead of failing silently.
local built = os.execute("(cd helpers && make -s >/dev/null)")
if not built then
  io.stderr:write("[sketchybar] helpers build failed: cpu/network widgets and the Apple menu will not work\n")
end
