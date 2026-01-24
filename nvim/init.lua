-- vim.g.loaded_netrw       = 1
-- vim.g.loaded_netrwPlugin = 1

vim.g.mapleader = " "
vim.loader.enable()
require 'options'
require 'extensions'
require 'keybinds'
require 'lsp'

vim.opt.timeoutlen = 500
