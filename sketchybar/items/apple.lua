local colors = require("colors")
local icons = require("icons")

-- Padding item required because of bracket
sbar.add("item", "apple.padding_left", { width = 5 })

local apple = sbar.add("item", "apple", {
	icon = {
		font = { size = 16.0 },
		string = icons.apple,
		padding_right = 8,
		padding_left = 8,
		color = colors.red,
	},
	label = { drawing = false },
	background = {
		color = colors.bg2,
		border_color = colors.red,
		border_width = 1,
	},
	padding_left = 1,
	padding_right = 1,
	click_script = "$CONFIG_DIR/helpers/menus/bin/menus -s 0",
})

-- Double border for apple using a single item bracket
sbar.add("bracket", "apple.bracket", { apple.name }, {
	background = {
		color = colors.transparent,
		height = 30,
		border_color = colors.red,
	},
})

-- Padding item required because of bracket
sbar.add("item", "apple.padding_right", { width = 7 })
