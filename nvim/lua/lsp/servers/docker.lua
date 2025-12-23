vim.lsp.config['dockerls'] = {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { '.git' },
}
