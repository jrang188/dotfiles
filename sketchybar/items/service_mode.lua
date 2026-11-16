local colors = require("colors")

-- AeroSpace's service mode (enter with alt-shift-;) was invisible on the bar: the
-- enter/leave events fired by nix/home/darwin/aerospace.nix had no subscriber
-- anywhere, so the mode could only be inferred from the window layout. Tint the
-- workspace items while it is active.
--
-- The tint goes on `background.color`, which is written once when a workspace
-- item is created and never touched again — the focus handlers only set
-- `border_width`, `label` and `icon` — so a workspace change mid-mode cannot
-- clobber it.
--
-- Subscribed on `root` (created by items/workspaces.lua, which loads first)
-- because sketchybar does not dispatch events to items with `drawing = false`:
-- a dedicated hidden subscriber item receives nothing.
local WORKSPACES = "/workspace\\..*/"

local function set_service_mode(active)
	sbar.set(WORKSPACES, {
		background = { color = active and colors.orange or colors.bg1 },
	})
end

sbar.subscribe("root", "aerospace_enter_service_mode", function()
	set_service_mode(true)
end)

sbar.subscribe("root", "aerospace_leave_service_mode", function()
	set_service_mode(false)
end)
