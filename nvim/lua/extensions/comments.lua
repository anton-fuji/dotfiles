require("Comment").setup({
  padding = true,
  sticky = true,
  ignore = nil,
  mappings = {
    basic = true,
    extra = true,
  },
  toggler = {
    line = 'gcc',
    block = 'gbc',
  },
  opleader = {
    line = 'gc',
    block = 'gb',
  },
  extra = {
    above = 'gc0',
    below = 'gco',
    eol = 'gcA',
  },
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
  post_hook = nil,
})

vim.keymap.set("n", "<leader>/", "gcc", { noremap = false, silent = true })
vim.keymap.set("v", "<leader>/", "gc", { noremap = false, silent = true })
