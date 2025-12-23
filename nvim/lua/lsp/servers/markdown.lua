vim.lsp.config['marksman'] = {
  cmd = { 'marksman', 'server' },
  filetypes = { 'markdown', 'md' },
  root_markers = { '.git', '.marksman.toml' },
  handlers = {
    ['textDocument/publishDiagnostics'] = function() end,
  },
}
