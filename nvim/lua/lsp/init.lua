
local ensure_installed = {
    'ts_ls', 
    'lua_ls', 
    'gopls',
    'pyright',
    'yamlls',
    'jsonls',
    'dockerls',
  }
  
  require 'mason'.setup()
  require 'mason-lspconfig'.setup {
    automatic_installation = true,
    ensure_installed = ensure_installed,
  }
  
  vim.lsp.config('lua_ls', {
    settings = {
      Lua = {
        diagnostics = {
          globals = { 'vim' }
        },
      }
    },
  })
  
vim.lsp.enable(ensure_installed)
