local ft = require("Comment.ft")

require("ts_context_commentstring").setup({
  enable_autocmd = false,  
})

require("Comment").setup({
  padding = true,
  sticky = true,
  ignore = "^$",
  mappings = {
    basic = true,
    extra = true,
    extend = true,
  },
  toggler = {
    line  = "gcc",
    block = "gbc",
  },
  opleader = {
    line  = "gc",
    block = "gb",
  },
  extra = {
    above = "gc0",
    below = "gco",
    eol   = "gcA",
  },
  pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
  post_hook = nil,
})

ft.set("lua",              { "--%s",   "--[[%s]]"   })
ft.set("go",               { "//%s",   "/*%s*/"     })
ft.set("python",           { "#%s",    "'''%s'''"   })
ft.set("javascript",       { "//%s",   "/*%s*/"     })
ft.set("typescript",       { "//%s",   "/*%s*/"     })
ft.set("typescriptreact",  { "//%s",   "{/*%s*/}"   })
ft.set("html",             { "<!--%s-->" })
