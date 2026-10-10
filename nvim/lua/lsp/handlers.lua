local group = vim.api.nvim_create_augroup('UserLsp', { clear = true })
local format_group = vim.api.nvim_create_augroup('UserLspFormat', { clear = true })

-- none-ls の整形ソースがなければ言語サーバーへ戻す。
local function formatter(bufnr)
  local clients = vim.lsp.get_clients({ bufnr = bufnr, method = 'textDocument/formatting' })
  table.sort(clients, function(a, b)
    if a.name == b.name then return a.id < b.id end
    return a.name < b.name
  end)

  for _, client in ipairs(clients) do
    if client.name == 'null-ls' then
      local sources = require('null-ls.sources')
      local method = require('null-ls.methods').internal.FORMATTING
      if #sources.get_available(vim.bo[bufnr].filetype, method) > 0 then
        return client
      end
    end
  end

  for _, client in ipairs(clients) do
    if client.name ~= 'null-ls' and not client:supports_method('textDocument/willSaveWaitUntil', bufnr) then
      return client
    end
  end
end

-- gopls exposes import cleanup as a code action, separate from formatting.
local function organize_go_imports(bufnr)
  if vim.bo[bufnr].filetype ~= 'go' then return end

  local params = vim.lsp.util.make_range_params()
  params.context = {
    only = { 'source.organizeImports' },
    diagnostics = {},
  }

  local responses = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 1000)
  for client_id, response in pairs(responses or {}) do
    for _, action in ipairs(response.result or {}) do
      if action.edit then
        local client = vim.lsp.get_client_by_id(client_id)
        vim.lsp.util.apply_workspace_edit(action.edit, client and client.offset_encoding or 'utf-16')
      end
    end
  end
end

vim.api.nvim_create_autocmd('LspAttach', {
  group = group,
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    if not client then return end

    if client:supports_method('textDocument/rename', ev.buf) then
      vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, {
        buffer = ev.buf, silent = true, desc = 'LSP: Rename symbol',
      })
    end

    if client:supports_method('textDocument/codeAction', ev.buf) then
      vim.keymap.set('n', '<leader>k', vim.lsp.buf.code_action, {
        buffer = ev.buf, silent = true, desc = 'LSP: Code action',
      })
    end

    -- 複数サーバーが接続しても、このバッファの保存処理は1つだけ。
    vim.api.nvim_clear_autocmds({ group = format_group, buffer = ev.buf })
    vim.api.nvim_create_autocmd('BufWritePre', {
      group = format_group,
      buffer = ev.buf,
      desc = 'Organize Go imports and format',
      callback = function()
        organize_go_imports(ev.buf)
        local selected = formatter(ev.buf)
        if selected then
          vim.lsp.buf.format({ bufnr = ev.buf, id = selected.id, timeout_ms = 1000 })
        end
      end,
    })
  end,
})
