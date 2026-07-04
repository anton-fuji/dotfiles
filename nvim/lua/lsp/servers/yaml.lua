vim.lsp.config['yamlls'] = {
  cmd = { 'yaml-language-server', '--stdio' },
  filetypes = { 'yaml', 'yml' },
  root_markers = { '.git', '.yaml' },
  settings = {
    yaml = {
      validate = true,
      hover = true,
      completion = true,
      schemas = {
        kubernetes = "/*.yaml",
      },
    },
  },
}
