vim.lsp.config['astro'] = {
  cmd = { 'astro-ls', '--stdio' },
  root_markers = { 'astro.config.mjs', 'package.json', '.git' },
  filetypes = { 'astro' },
  init_options = {
    typescript = {}, -- TypeScriptの型補完を有効にするため
  },
}
