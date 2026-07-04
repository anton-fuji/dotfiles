vim.lsp.config['pyright'] = {
  cmd = { 'pyright-langserver', '--stdio' },
  root_markers = { '.git', 'pyproject.toml', 'setup.py', 'setup.cfg' },
  filetypes = { 'python' },
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
      },
    },
  },
}
