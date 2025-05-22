-- LSP Configuration (Unified in init.lua)
vim.lsp.config['gopls'] = {
  cmd = { 'gopls' },
  root_markers = { 'go.mod', '.git', 'go.work' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  settings = {
    gopls = {
      analyses = { unusedparams = true },
      staticcheck = true,
    },
  },
}

vim.lsp.config['lua_ls'] = {
  cmd = { 'lua-language-server' },
  root_markers = { '.luarc.json', '.luarc.jsonc', '.luacheckrc', '.stylua.toml', 'init.lua', '.git' },
  filetypes = { 'lua' },
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
        pathStrict = true,
        path = { "?.lua", "?/init.lua" },
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.list_extend(vim.api.nvim_get_runtime_file("lua", true), {
          "${3rd}/luv/library",
          "${3rd}/busted/library",
          "${3rd}/luassert/library",
        }),
        checkThirdParty = "Disable",
      },
    },
  }
}

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

vim.lsp.config['dockerls'] = {
  cmd = { 'docker-langserver', '--stdio' },
  filetypes = { 'dockerfile' },
  root_markers = { '.git' },
}

vim.lsp.config['tsserver'] = {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 'typescript', 'typescriptreact', 'javascript', 'javascriptreact' },
  root_markers = { 'package.json', 'tsconfig.json', '.git' },
  settings = {
    typescript = {
      preferences = {
        importModuleSpecifier = "relative",
      },
    },
  },
}

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

vim.lsp.config['clangd'] = {
  cmd = { 'clangd', '--background-index' },
  filetypes = { 'c', 'cpp', 'objcpp' },
  root_markers = { 'compile_commands.json', '.git', 'compile_flags.txt' }
}

-- Enable all Language Servers
vim.lsp.enable({ 'gopls', 'lua_ls', 'pyright', 'dockerls', 'tsserver', 'yamlls', 'clangd' })

-- Keymaps of LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    local keyopts = { remap = true, silent = true }
    if client:supports_method('textDocument/implementation') then
      vim.keymap.set('n', 'gD', vim.lsp.buf.implementation, keyopts)
    end
    if client:supports_method('textDocument/definition') then
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, keyopts)
    end
    if client:supports_method('textDocument/typeDefinition') then
      vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, keyopts)
    end
    if client:supports_method('textDocument/references') then
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, keyopts)
    end
    if client:supports_method('textDocument/rename') then
      vim.keymap.set('n', 'gn', vim.lsp.buf.rename, keyopts)
    end
    if client:supports_method('textDocument/codeAction') then
      vim.keymap.set('n', '<Leader>k', vim.lsp.buf.code_action, keyopts)
    end
    if client:supports_method('textDocument/signatureHelp') then
      vim.api.nvim_create_autocmd('CursorHoldI', {
        pattern = '*',
        callback = function()
          vim.lsp.buf.signature_help({ focus = false, silent = true })
        end
      })
    end
  end,
})

-- Auto format on save
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
    if not client:supports_method('textDocument/willSaveWaitUntil') and client:supports_method('textDocument/formatting') then
      vim.api.nvim_create_autocmd('BufWritePre', {
        buffer = ev.buf,
        callback = function()
          vim.lsp.buf.format({ bufnr = ev.buf, timeout_ms = 1000 })
        end
      })
    end
  end
})

-- Diagnostics 設定
vim.diagnostic.config({
  virtual_text = {
    prefix = "👽",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})
