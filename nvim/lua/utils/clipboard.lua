-- clipboard=unnamedplus は削除(dd 等)のたびに pbcopy を呼ぶため使わない。
-- ヤンクしたときだけシステムクリップボードへ送り、
-- フォーカスが戻ったときにシステムクリップボードを無名レジスタへ取り込む。
local M = {}

local last_imported

function M.setup()
  local group = vim.api.nvim_create_augroup("clipboard_sync", { clear = true })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = group,
    callback = function()
      local ev = vim.v.event
      if ev.operator ~= "y" or ev.regname ~= "" then
        return
      end
      local text = table.concat(ev.regcontents, "\n")
      last_imported = text
      vim.fn.setreg("+", ev.regcontents, ev.regtype)
    end,
  })

  vim.api.nvim_create_autocmd("FocusGained", {
    group = group,
    callback = function()
      local ok, text = pcall(vim.fn.getreg, "+")
      if not ok or text == "" or text == last_imported then
        return
      end
      last_imported = text
      vim.fn.setreg('"', text, vim.fn.getregtype("+"))
    end,
  })
end

return M
