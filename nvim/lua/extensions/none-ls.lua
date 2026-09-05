local nls = require("null-ls")
local eslint_d = require("none-ls.diagnostics.eslint_d")
nls.setup({
  sources = {
    nls.builtins.formatting.prettierd,
    eslint_d,
    nls.builtins.formatting.stylua,
  },
})
