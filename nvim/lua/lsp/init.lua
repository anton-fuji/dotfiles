-- LSP Configuration
require('lsp.servers.go')
require('lsp.servers.rust')
require('lsp.servers.lua')
require('lsp.servers.python')
require('lsp.servers.docker')
require('lsp.servers.typescript')
require('lsp.servers.yaml')
require('lsp.servers.c')
require('lsp.servers.markdown')
require('lsp.servers.terraform')
require('lsp.servers.nix')

-- ハンドラーとDiagnostics設定
require('lsp.handlers')
require('lsp.diagnostics')

-- すべてのLanguage Serverを有効化
vim.lsp.enable({
  'gopls',
  'rust_analyzer',
  'lua_ls',
  'pyright',
  'dockerls',
  'tsserver',
  'yamlls',
  'terraformls',
  'clangd',
  'marksman',
  'nil_ls',
})
