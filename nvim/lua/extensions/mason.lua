require("mason").setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
      border = "rounded",
    },
    max_concurrent_installers = 4,
    log_level = vim.log.levels.INFO,
  })
  
  
  require("mason-lspconfig").setup({
    ensure_installed = {
      "ts_ls",
      "lua_ls",
      "gopls",
      "pyright",
      "jsonls",
      "yamlls",
      "dockerls",
      "marksman",
      "ltex",
    },
    automatic_installation = true,
})
