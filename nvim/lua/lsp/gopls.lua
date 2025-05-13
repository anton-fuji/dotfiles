return {
    cmd       = { "gopls" },
    filetypes = { "go", "gomod" },
    root_dir  = function(fname)
      return vim.fs.find({ "go.work", "go.mod", ".git" }, { upward = true, path = fname })[1]
        or vim.fn.getcwd()
    end,
    on_attach = function(client, bufnr)
      -- 必要なら on_attach 処理
    end,
    settings = {
      gopls = {
        analyses     = { unusedparams = true },
        staticcheck  = true,
      },
    },
  }
  
  