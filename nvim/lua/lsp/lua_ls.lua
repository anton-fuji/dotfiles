
vim.cmd([[ set completeopt+=menuone,noselect,popup ]])

vim.api.nvim_create_autocmd("FileType", {
  pattern = "lua",
  callback = function()
    vim.lsp.start({
      name     = "lua_ls",
      cmd      = { "lua-language-server" },
      root_dir = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
      on_attach = function(client, bufnr)
        -- 自動補完を有効化
        vim.lsp.completion.enable(true, client.id, bufnr, {
          autotrigger = true,
          convert     = function(item)
            return { abbr = item.label:gsub("%b()", "") }
          end,
        })
        -- ここにキーマップを追加
      end,
      settings = {
        Lua = {
          diagnostics = {
            unusedLocalExclude = { "_*" },
          },
        },
      },
    })
  end,
})
