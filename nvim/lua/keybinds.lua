-- Normal to Command (コマンド入力をより使いやすく)
vim.keymap.set("n", ":", ";")
vim.keymap.set("n", ";", ":")

-- ペースト後にカーソルを移動しない
vim.keymap.set("v", "y", "y`]")
vim.keymap.set({ "v", "n" }, "p", "p`]")

-- レジスタを汚さないように
vim.keymap.set("n", "x", '"_x')
vim.keymap.set("n", "X", '"_X')
vim.keymap.set("n", "s", '"_s')

vim.keymap.set("i", "jj", "<ESC>:<C-u>w<CR>")
vim.keymap.set({ "i", "c" }, "<M-k>", "\\", { noremap = true, silent = true })

-- カーソル移動
vim.keymap.set("n", "gh", "^")
vim.keymap.set("n", "gl", "$")

-- leader設定
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })
vim.g.mapleader      = " "
vim.g.maplocalleader = "\\"

-- 選択系
vim.keymap.set('n', '<C-a>', 'ggVG', { noremap = true, silent = true })
vim.keymap.set('v', '<C-a>', '<Esc>ggVG', { noremap = true, silent = true })

-- スクロール
vim.keymap.set("n", "<C-j>", "20j", { noremap = true, silent = true })
vim.keymap.set("n", "<C-k>", "20k", { noremap = true, silent = true })

-- 新規タブでterminalを開く
vim.keymap.set("n", "tt", function()
  vim.cmd("tabnew | terminal")
end, { silent = true })

-- 下部にterminalを表示
vim.keymap.set("n", "te", function()
  vim.cmd("belowright split | terminal")
  vim.cmd("resize 15")
end, { silent = true })

-- <Esc> Normalモード
vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { silent = true })
