local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
	display = "active",
	icon = { drawing = false },
	label = {
		font = {
			style = settings.font.style_map["Black"],
			size = 12.0,
		},
	},
	updates = true,
})

front_app:subscribe("front_app_switched", function(env)
	front_app:set({ label = { string = env.INFO } })
end)

-- Note: upstream also swaps in its menu-bar inspector here
-- (`sbar.trigger("swap_menus_and_spaces")`), but this config never loads
-- `items/menus.lua`, so that event is unregistered and the trigger is a no-op.
