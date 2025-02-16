-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
if not vim.g.vscode then
  vim.keymap.set(
    "n",
    "<leader>sx",
    require("fzf-lua").resume,
    { noremap = true, silent = true, desc = "Resume" }
  )
end
