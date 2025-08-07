-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.o.number = true
vim.o.relativenumber = false

vim.o.guicursor = table.concat({
  "n-v-o-i-c:ver25",
  "r:hor20",
  "sm:block-blinkon175-blinkoff150-blinkon175",
}, ",")

vim.cmd([[ set conceallevel=0 ]])
vim.cmd([[ set concealcursor= ]])
