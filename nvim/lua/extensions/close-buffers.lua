return {
  "kazhala/close-buffers.nvim",
  lazy = false,
  config = function()
    require("close_buffers").setup({
      filetype_ignore = {},                            -- 削除時に無視するファイルタイプ
      file_glob_ignore = {},                           -- 削除時に無視するファイル名のグロブパターン (例: '*.md')
      file_regex_ignore = {},                          -- 削除時に無視するファイル名の正規表現パターン (例: '.*[.]md')
      preserve_window_layout = { "this", "nameless" }, -- ウィンドウレイアウトを保持する削除タイプ
      next_buffer_cmd = nil,                           -- ウィンドウレイアウト保持時の次のバッファ取得用カスタム関数
    })

    local opts = { noremap = true, silent = true }

    -- 非表示のバッファを全て削除
    vim.keymap.set("n", "<leader>bh", [[<CMD>lua require('close_buffers').delete({type = 'hidden'})<CR>]], opts)

    -- 名前のないバッファを全て削除
    vim.keymap.set("n", "<leader>bu", [[<CMD>lua require('close_buffers').delete({type = 'nameless'})<CR>]], opts)

    -- 現在のバッファを削除（ウィンドウレイアウトを保持）
    vim.keymap.set("n", "<leader>bc", [[<CMD>lua require('close_buffers').delete({type = 'this'})<CR>]], opts)

    -- 現在のバッファ以外を全て削除
    vim.keymap.set("n", "<leader>bo", [[<CMD>lua require('close_buffers').delete({type = 'other'})<CR>]], opts)

    -- 全てのバッファを削除
    vim.keymap.set("n", "<leader>ba", [[<CMD>lua require('close_buffers').delete({type = 'all', force = true})<CR>]],
      opts)
  end,
}
