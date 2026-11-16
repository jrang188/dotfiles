local icons = require("icons")
local colors = require("colors")

-- `media_change` is deprecated on macOS 26 — MediaRemote no longer delivers it
-- (it also fed the built-in `media.artwork` image provider), so this widget polls
-- `nowplaying-cli` instead. `nowplaying-cli get <keys>` prints one value per line
-- in argument order, and `null` for anything absent.
--
-- The previous implementation filtered on the playing application's name
-- (Spotify/Music). `nowplaying-cli` exposes no application identifier among its
-- documented keys, so that whitelist is gone: anything now-playing will show. If
-- that proves noisy, the app name can be recovered by parsing `get-raw` when the
-- track changes.
local POLL_INTERVAL = 2
local tmpdir = (os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "")

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	background = {
		image = { drawing = false, scale = 0.85 },
		color = colors.transparent,
	},
	label = { drawing = false },
	icon = { drawing = false },
	drawing = false,
	popup = {
		align = "center",
		horizontal = true,
	},
})

local media_artist = sbar.add("item", "media.artist", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	width = 0,
	icon = { drawing = false },
	label = {
		width = 0,
		font = { size = 9 },
		color = colors.with_alpha(colors.white, 0.6),
		max_chars = 18,
		y_offset = 6,
	},
})

local media_title = sbar.add("item", "media.title", {
	position = "right",
	drawing = false,
	padding_left = 3,
	padding_right = 0,
	icon = { drawing = false },
	label = {
		font = { size = 11 },
		width = 0,
		max_chars = 16,
		y_offset = -5,
	},
})

sbar.add("item", "media.popup.previous", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.back },
	label = { drawing = false },
	click_script = "nowplaying-cli previous",
})
sbar.add("item", "media.popup.play_pause", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "nowplaying-cli togglePlayPause",
})
sbar.add("item", "media.popup.next", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "nowplaying-cli next",
})

local interrupt = 0
local function animate_detail(detail)
	if not detail then
		interrupt = interrupt - 1
	end
	if interrupt > 0 and not detail then
		return
	end

	sbar.animate("tanh", 30, function()
		media_artist:set({ label = { width = detail and "dynamic" or 0 } })
		media_title:set({ label = { width = detail and "dynamic" or 0 } })
	end)
end

local function hide_media()
	media_cover:set({ drawing = false, popup = { drawing = false } })
	media_artist:set({ drawing = false })
	media_title:set({ drawing = false })
end

local function show_media(title, artist)
	media_artist:set({ drawing = true, label = artist })
	media_title:set({ drawing = true, label = title })
	media_cover:set({ drawing = true })
	interrupt = interrupt + 1
	animate_detail(true)
	sbar.delay(5, animate_detail)
end

-- djb2, so each track gets its own artwork file. Reusing one path would leave
-- sketchybar showing a cached image.
local function string_hash(value)
	local hash = 5381
	for i = 1, #value do
		hash = (hash * 33 + value:byte(i)) % 2147483647
	end
	return hash
end

local function fetch_artwork(key)
	local path = string.format("%s/sketchybar-artwork-%d.png", tmpdir, string_hash(key))
	-- `get artworkData` yields base64; it prints `null` when the track has no
	-- art, which base64 rejects, so the non-zero exit doubles as the skip case.
	sbar.exec("nowplaying-cli get artworkData | base64 -D > '" .. path .. "'", function(_, code)
		if code == 0 then
			media_cover:set({ background = { image = { string = path, drawing = true } } })
		end
	end)
end

local current_title = nil
local visible = false

local function on_nowplaying(result)
	local values = {}
	for line in result:gmatch("[^\r\n]+") do
		values[#values + 1] = line
	end
	local title, artist, rate = values[1], values[2], values[3]

	local present = title ~= nil and title ~= "null"
	local playing = present and rate ~= nil and rate ~= "null" and (tonumber(rate) or 0) > 0

	if not playing then
		if visible then
			hide_media()
			visible = false
		end
		if not present then
			current_title = nil
		end
		return
	end

	if not visible then
		visible = true
		show_media(title, artist ~= "null" and artist or "")
	end

	if title ~= current_title then
		current_title = title
		-- Drop the previous track's art immediately, then fill in if it has any.
		media_cover:set({ background = { image = { drawing = false } } })
		fetch_artwork(title .. "|" .. tostring(artist))
	end
end

local polling = false
local function poll_media()
	if not polling then
		polling = true
		sbar.exec("nowplaying-cli get title artist playbackRate", function(result, code)
			polling = false
			if code == 0 and result then
				on_nowplaying(result)
			end
		end)
	end
	sbar.delay(POLL_INTERVAL, poll_media)
end

poll_media()

media_cover:subscribe("mouse.entered", function(env)
	interrupt = interrupt + 1
	animate_detail(true)
end)

media_cover:subscribe("mouse.exited", function(env)
	animate_detail(false)
end)

media_cover:subscribe("mouse.clicked", function(env)
	media_cover:set({ popup = { drawing = "toggle" } })
end)

media_title:subscribe("mouse.exited.global", function(env)
	media_cover:set({ popup = { drawing = false } })
end)
