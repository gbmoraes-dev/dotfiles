-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--[[ 
-- ===================================================================
-- GUIA DE REFERÊNCIA DE ATALHOS
-- ===================================================================
--
-- Comandos Nativos Úteis para Lembrar:
--
-- zz: Centraliza a tela na posição atual do cursor.
-- <C-o>: Volta para a posição anterior do cursor na "jumplist".
-- <C-i>: Avança para a próxima posição do cursor na "jumplist".
--
-- Atalhos do Telescope (Plugin de Busca):
--
-- <leader>ff: Encontrar arquivos no projeto.
-- <leader>fg: Buscar por texto em todos os arquivos do projeto.
-- <leader>fb: Buscar nos buffers (arquivos abertos).
--]]

local map = vim.keymap.set

-- Manipulação de Texto
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Mover linha para baixo" })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Mover linha para cima" })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Mover seleção para baixo" })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Mover seleção para cima" })

-- Navegação entre Buffers
map("n", "<leader><Left>", "<cmd>bprevious<cr>", { desc = "Buffer Anterior" })
map("n", "<leader><Right>", "<cmd>bnext<cr>", { desc = "Próximo Buffer" })

-- Ferramentas e Plugins
map("n", "<leader>gg", function()
  local Util = require("lazyvim.util")
  Util.terminal.open("lazygit", { direction = "float" })
end, { desc = "LazyGit" })

-- Neotest
map("n", "<leader>tt", function()
  require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run File Tests" })
map("n", "<leader>tT", function()
  require("neotest").run.run(vim.loop.cwd())
end, { desc = "Run All Tests" })
map("n", "<leader>tr", function()
  require("neotest").run.run()
end, { desc = "Run Nearest Test" })
map("n", "<leader>ts", function()
  require("neotest").summary.toggle()
end, { desc = "Toggle Test Summary" })
map("n", "<leader>to", function()
  require("neotest").output.open({ enter = true })
end, { desc = "Show Test Output" })
