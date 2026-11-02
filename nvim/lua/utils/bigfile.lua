-- 大きいファイルを開いたときに、重い処理(treesitter・スクロールアニメーション等)を止める。
local M = {}

M.max_size = 1024 * 1024 -- 1MB

---@param buf? integer
---@return boolean
function M.is_big(buf)
  if buf == nil or buf == 0 then
    buf = vim.api.nvim_get_current_buf()
  end
  if vim.b[buf].bigfile ~= nil then
    return vim.b[buf].bigfile
  end
  local stat = vim.uv.fs_stat(vim.api.nvim_buf_get_name(buf))
  return stat ~= nil and stat.size > M.max_size
end

function M.setup()
  vim.api.nvim_create_autocmd("BufReadPre", {
    group = vim.api.nvim_create_augroup("bigfile", { clear = true }),
    callback = function(args)
      vim.b[args.buf].bigfile = nil
      local big = M.is_big(args.buf)
      vim.b[args.buf].bigfile = big
      if not big then
        return
      end
      vim.b[args.buf].minianimate_disable = true
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.foldmethod = "manual"
    end,
  })
end

return M
