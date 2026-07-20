return {
  "kazhala/close-buffers.nvim",
  keys = {
    { "<leader>bh", function() require("close_buffers").delete({ type = "hidden" }) end, desc = "Delete Hidden Buffers" },
    { "<leader>bu", function() require("close_buffers").delete({ type = "nameless" }) end, desc = "Delete Nameless Buffers" },
    { "<leader>bc", function() require("close_buffers").delete({ type = "this" }) end, desc = "Delete Current Buffer" },
    { "<leader>bo", function() require("close_buffers").delete({ type = "other" }) end, desc = "Delete Other Buffers" },
    { "<leader>ba", function() require("close_buffers").delete({ type = "all", force = true }) end, desc = "Delete All Buffers" },
  },
  config = function()
    require("close_buffers").setup({
      filetype_ignore = {},                            -- 削除時に無視するファイルタイプ
      file_glob_ignore = {},                           -- 削除時に無視するファイル名のグロブパターン (例: '*.md')
      file_regex_ignore = {},                          -- 削除時に無視するファイル名の正規表現パターン (例: '.*[.]md')
      preserve_window_layout = { "this", "nameless" }, -- ウィンドウレイアウトを保持する削除タイプ
      next_buffer_cmd = nil,                           -- ウィンドウレイアウト保持時の次のバッファ取得用カスタム関数
    })
  end,
}
