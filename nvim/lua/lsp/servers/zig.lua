vim.lsp.config['zls'] = {
  cmd = { 'zls' },
  root_markers = { 'build.zig', 'build.zig.zon', '.git' },
  filetypes = { 'zig', 'zir' },
  settings = {
    zls = {
      enable_autofix = true,
    },
  },
}
