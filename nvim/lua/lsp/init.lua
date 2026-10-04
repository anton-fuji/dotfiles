-- Keep each configuration module paired with its Neovim LSP name.
local servers = {
  { module = 'go', name = 'gopls' },
  { module = 'rust', name = 'rust_analyzer' },
  { module = 'lua', name = 'lua_ls' },
  { module = 'python', name = 'pyright' },
  { module = 'docker', name = 'dockerls' },
  { module = 'typescript', name = 'ts_ls' },
  { module = 'tailwindcss', name = 'tailwindcss' },
  { module = 'yaml', name = 'yamlls' },
  { module = 'c', name = 'clangd' },
  { module = 'markdown', name = 'marksman' },
  { module = 'terraform', name = 'terraformls' },
  { module = 'nix', name = 'nil_ls' },
  { module = 'astro', name = 'astro' },
  { module = 'zig', name = 'zls' },
}

local enabled_servers = {}
for _, server in ipairs(servers) do
  require('lsp.servers.' .. server.module)
  table.insert(enabled_servers, server.name)
end

-- ハンドラーとDiagnostics設定
require('lsp.handlers')
require('lsp.diagnostics')

-- すべてのLanguage Serverを有効化
vim.lsp.enable(enabled_servers)
