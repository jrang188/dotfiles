-- Quote a string for /bin/sh so it survives as a single argv element.
-- User-supplied values (an audio device name, a WiFi SSID) may contain quotes,
-- `$` or backticks; interpolating them into double quotes lets the shell expand
-- them.
local function quote(value)
  return "'" .. (value or ""):gsub("'", "'\\''") .. "'"
end

return {
  quote = quote,
}
