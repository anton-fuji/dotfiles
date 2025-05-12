
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
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "$")
