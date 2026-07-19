vim.lsp.config['ts_ls'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'javascript',
    'javascriptreact',
    'javascript.jsx',
  },
  root_markers = { 'package.json', 'tsconfig.json', '.git' },
  settings = {
    typescript = {
      preferences = {
        importModuleSpecifier = "relative",
      },
    },
  },
}
