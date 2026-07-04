local nls = require("none-ls")
nls.setup({
  sources = {
    nls.builtins.formatting.prettierd,
    nls.builtins.diagnostics.eslint_d,
    nls.builtins.formatting.stylua,
  },
})

