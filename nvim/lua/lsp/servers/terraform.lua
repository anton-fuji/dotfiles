vim.lsp.config['terraformls'] = {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'tf', 'terraform-vars' },
  root_markers = { '.terraform', '.git', 'terraform.tfvars' },
  settings = {
    terraform = {
      validation = {
        enableEnhancedValidation = true,
      },
    },
  },
}
