-- global
vim.opt.termguicolors = true
vim.opt.scrolloff = 4
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

-- buffer
vim.opt.swapfile = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 0
vim.opt.expandtab = true

-- highlight
vim.api.nvim_set_hl(0, "CursorLine", { bg = "#F1009A", nocombine = true })
vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#FFC0CB", bold = true })
vim.api.nvim_set_hl(0, "Visual", { bg = "#F1009A" })
