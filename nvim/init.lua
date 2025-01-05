-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

-- setup clipboard in WSL2
vim.g.clipboard = {
  name = "WslClipboard",
  copy = {
    ["+"] = "clip.exe",
    ["*"] = "clip.exe"
  },
  paste = {
    ["+"] =
    'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
    ["*"] =
    'powershell.exe -NoLogo -NoProfile -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))'
  },
  cache_enabled = 0
}
