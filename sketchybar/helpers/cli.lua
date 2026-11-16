-- Resolution of the external command-line tools this config shells out to.
--
-- sketchybar is started by `brew services` (a launchd agent with KeepAlive), so
-- its environment is tiny:
--
--   PATH=/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:/sbin
--
-- AeroSpace, nowplaying-cli and SwitchAudioSource are installed by Nix and live
-- only in the Nix profiles (e.g. /etc/profiles/per-user/$USER/bin), which is not
-- on that PATH. A bare `sbar.exec("aerospace ...")` or click_script therefore
-- dies with "sh: <tool>: command not found" — that is what silently emptied the
-- workspace items and the audio-device popup.
--
-- resolve() returns an absolute path for a command, and falls back to the bare
-- name so that setups with a correct PATH keep working unchanged.

local home = os.getenv("HOME") or ""
local user = os.getenv("USER") or ""

-- Search order matters: Nix first (the declarative source of truth), Homebrew
-- last (legacy casks/formulae).
local bin_dirs = {
	"/etc/profiles/per-user/" .. user .. "/bin", -- nix-darwin system profile
	home .. "/.nix-profile/bin", -- multi-user Nix profile
	"/run/current-system/sw/bin", -- NixOS
	"/opt/homebrew/bin", -- Homebrew formulae + old cask symlinks
	"/usr/local/bin",
}

local function readable(path)
	local file = io.open(path, "r")
	if file == nil then
		return false
	end
	file:close()
	return true
end

local function resolve(name)
	for _, dir in ipairs(bin_dirs) do
		local path = dir .. "/" .. name
		if readable(path) then
			return path
		end
	end
	return name
end

return {
	resolve = resolve,
}
