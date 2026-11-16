local icons = require("icons")
local colors = require("colors")

-- `media_change` is deprecated on macOS 26, so this widget polls instead. The
-- poller is `media-control`, not `nowplaying-cli`: on this macOS version
-- `nowplaying-cli get <key>` returns `null` for every key while
-- `media-control get` returns the full now-playing dictionary and
-- `media-control test` passes. `media-control get` emits JSON, and SbarLua's
-- exec callback decodes JSON into a table automatically, so there is no parsing
-- here.
--
-- `get` also embeds the cover as base64 in `artworkData`, which makes the payload
-- 100+ KB. The poll strips that field in the shell (down to ~470 bytes) and the
-- artwork is fetched separately, only when the track changes.
--
-- The fetched image is normalised to 56px and drawn with `scale = 0.5`, i.e. at
-- 28pt — the item's background height. `scale` multiplies the image's *natural*
-- size, so a 600px cover with the old `scale = 0.85` rendered 510px wide across
-- the whole bar.
local POLL_INTERVAL = 2
local ARTWORK_SIZE = 56
local WHITELIST = {
	["com.spotify.client"] = true,
	["com.apple.Music"] = true,
}
local tmpdir = (os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "")

local media_cover = sbar.add("item", "media.cover", {
	position = "right",
	background = {
		image = { drawing = false, scale = 0.5 },
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
	click_script = "media-control previous-track",
})
sbar.add("item", "media.popup.play_pause", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.play_pause },
	label = { drawing = false },
	click_script = "media-control toggle-play-pause",
})
sbar.add("item", "media.popup.next", {
	position = "popup." .. media_cover.name,
	icon = { string = icons.media.forward },
	label = { drawing = false },
	click_script = "media-control next-track",
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
	local raw = string.format("%s/sketchybar-artwork-%d.raw", tmpdir, string_hash(key))
	local path = string.format("%s/sketchybar-artwork-%d.png", tmpdir, string_hash(key))
	sbar.exec(
		"media-control get | plutil -extract artworkData raw -o - - | base64 -D > '" .. raw .. "'"
			.. " && sips -Z " .. ARTWORK_SIZE .. " -s format png '" .. raw .. "' --out '" .. path .. "' >/dev/null"
			.. " && rm -f '" .. raw .. "'",
		function(_, code)
			if code == 0 then
				media_cover:set({ background = { image = { string = path, drawing = true } } })
			end
		end
	)
end

local current_key = nil
local visible = false

local function hide_if_visible()
	if visible then
		hide_media()
		visible = false
	end
end

local function on_nowplaying(data)
	-- `media-control get` prints nothing when no player is active, in which case
	-- the callback receives a string rather than a decoded table.
	if type(data) ~= "table" then
		hide_if_visible()
		current_key = nil
		return
	end

	local playing = data.playing == true
		or data.playing == "true"
		or (tonumber(data.playbackRate) or 0) > 0
	local bundle = data.bundleIdentifier
	local allowed = bundle ~= nil and WHITELIST[bundle] == true

	if not (playing and allowed) then
		hide_if_visible()
		if not playing then
			current_key = nil
		end
		return
	end

	local title = data.title or ""
	local artist = data.artist or ""
	if not visible then
		visible = true
		show_media(title, artist)
	end

	-- `contentItemIdentifier` is stable per queue item, so it survives a
	-- metadata refresh in a way that title|artist does not.
	local key = data.contentItemIdentifier or (title .. "|" .. artist)
	if key ~= current_key then
		current_key = key
		-- Drop the previous track's art immediately, then fill in if it has any.
		media_cover:set({ background = { image = { drawing = false } } })
		fetch_artwork(key)
	end
end

-- `artworkData` sits mid-object, so the stripping pattern eats its trailing
-- comma; the remainder is still valid JSON (470 bytes instead of 120 KB).
local POLL_COMMAND = [[media-control get | sed 's/"artworkData":"[^"]*",//']]

local polling = false
local function poll_media()
	if not polling then
		polling = true
		sbar.exec(POLL_COMMAND, function(data, code)
			polling = false
			if code == 0 then
				on_nowplaying(data)
			end
		end)
	end
	sbar.delay(POLL_INTERVAL, poll_media)
end

-- Start after the initial config batch has been committed and the event loop is
-- running: polling from load time races the `begin_config`/`end_config` batch,
-- which can swallow the first artwork update.
sbar.delay(1, poll_media)

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
