vim.lsp.config['clangd'] = {
  cmd = { 'clangd', '--background-index' },
  filetypes = { 'c', 'cpp', 'objcpp' },
  root_markers = { 'compile_commands.json', '.git', 'compile_flags.txt' }
}
