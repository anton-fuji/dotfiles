return {
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      lsp = {
        progress = { enabled = false },
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = false,
        lsp_doc_border = false,
      },
      routes = {
        -- info レベルの通知を非表示
        -- info レベルの通知を非表示（kind はログレベルの文字列）
        {
          filter = { event = "notify", kind = "info" },
          opts = { skip = true },
        },
        -- 保存・編集系メッセージを非表示
        {
          filter = {
            event = "msg_show",
            any = {
              { find = "%d+L, %d+B" },
              { find = "; after #%d+" },
              { find = "; before #%d+" },
              { find = "%d fewer lines" },
              { find = "%d more lines" },
            },
          },
          opts = { skip = true },
        },
        -- ヤンクメッセージを非表示
        {
          filter = {
            event = "msg_show",
            kind = "",
            find = "yanked",
          },
          opts = { skip = true },
        },
      },
    },
    dependencies = {
      "MunifTanjim/nui.nvim",
      {
        "rcarriga/nvim-notify",
        opts = {
          timeout = 2000,              -- 表示時間を2秒に短縮（デフォルト5秒）
          minimum_width = 10,
          level = vim.log.levels.WARN, -- INFO未満は表示しない
        },
      },
    },
  },
}
