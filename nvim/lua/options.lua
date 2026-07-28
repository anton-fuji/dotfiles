-- global
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = 'split'
vim.opt.clipboard = 'unnamedplus'

-- window
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = 'yes:1'
vim.opt.wrap = false
vim.opt.list = true
vim.opt.listchars = {
  tab = "▸ ",
  trail = "·",
  nbsp = "␣",
}
vim.opt.showmode = false
vim.opt.cmdheight = 0
vim.opt.fillchars = {
  horiz = "─",
  horizup = "┴",
  horizdown = "┬",
  vert = "│",
  vertleft = "┤",
  vertright = "├",
  verthoriz = "┼",
}

-- buffer
vim.opt.swapfile = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0
vim.opt.expandtab = true
