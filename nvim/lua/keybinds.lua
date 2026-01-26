-- Normal to Command (コマンド入力をより使いやすく)
-- vim.keymap.set("n", ":", ";")
-- vim.keymap.set("n", ";", ":")

-- 絶対行・相対行表示
vim.opt.number = true
vim.opt.relativenumber = true

-- ペースト後にカーソルを移動しない
vim.keymap.set("v", "y", "y`]")
vim.keymap.set({ "v", "n" }, "p", "p`]")

-- レジスタを汚さないように
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "X", '"_X')
vim.keymap.set("n", "s", '"_s')

vim.keymap.set("i", "jj", "<ESC>:<C-u>w<CR>")
vim.keymap.set({ 'i', 'c' }, '<M-k>', '\\', { noremap = true, silent = true })

-- スペース
vim.keymap.set("i", "<S-Space>", "    ", { noremap = true, silent = true, desc = 'Insert 4 spaces' })

-- leader設定
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- 選択系
-- vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true, silent = true })
-- vim.keymap.set('v', '<C-a>', '<Esc>ggVG', { noremap = true, silent = true })

-- スプリット (非leader系)
-- vim.keymap.set("n", "<S-j>", ":split<CR>", { silent = true })
-- vim.keymap.set("n", "<S-l>", ":vsplit<CR>", { silent = true })

-- ウィンドウ移動
vim.keymap.set("n", "<C-h>", "<C-w>h", { silent = true })
vim.keymap.set("n", "<C-j>", "<C-w>j", { silent = true })
vim.keymap.set("n", "<C-k>", "<C-w>k", { silent = true })
vim.keymap.set("n", "<C-l>", "<C-w>l", { silent = true })


-- スクロール
vim.keymap.set("n", "<C-j>", "20j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "20k", { noremap = true, silent = true })

-- 新規タブでterminalを開く
vim.keymap.set("n", "tt", function()
  vim.cmd("tabnew | terminal")
end, { silent = true })

-- 下部にterminalを表示
-- vim.keymap.set("n", "te", function()
--   vim.cmd("belowright split | terminal")
--   vim.cmd("resize 20")
-- end, { silent = true })

vim.keymap.set("n", "te", function()
  -- 既に開いていたら閉じる・閉じてたら開く
  vim.cmd("ToggleTerm direction=horizontal")
end, { silent = true, desc = "ToggleTerm: 横分割ターミナル" })


-- <Esc> Normalモード
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true })

-- Oil
vim.keymap.set("n", "<leader>-", "<CMD>Oil .<CR>", { desc = "Open cwd" })

-- Window Resize
vim.keymap.set("n", "<C-n>", function()
  print("Resize: h/l (ESC to exit)")
  while true do
    local key = vim.fn.getchar()
    local char = type(key) == "number" and vim.fn.nr2char(key) or key

    if char == "h" then
      vim.cmd("vertical resize -3")
    elseif char == "l" then
      vim.cmd("vertical resize +3")
    elseif key == 27 then -- ESC
      print("")
      break
    end
  end
end, { desc = "Resize mode" })
