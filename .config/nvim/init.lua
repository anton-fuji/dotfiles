local opt = vim.opt

-- Set width for 2-byte characters to double
opt.ambiwidth = 'double'

-- Enable automatic indentation
opt.autoindent = true
-- Enable smart indentation
opt.smartindent = true

-- Set the number of spaces that a <Tab> in the file counts for
opt.tabstop = 4
-- Set the number of spaces that a <Tab> counts for while performing editing operations
opt.softtabstop = 4

-- Show line numbers
opt.number = true

-- Load the package manager
require('plugin_manager')

-- Load plugins
require('plugins')


-- Apply plugin settings
require('plugins.tokyonight')
require('plugins.nvim-tree')
require('plugins.nvim-web-devicons')
