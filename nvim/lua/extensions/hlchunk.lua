return {
  "shellRaining/hlchunk.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("hlchunk").setup({
      chunk = {
        enable = true,
        priority = 15,
        style = {
          { fg = "#7aa2f7" },
          { fg = "#f7768e" },
        },
        use_treesitter = true,
        chars = {
          horizontal_line = "─",
          vertical_line = "│",
          left_top = "╭",
          left_bottom = "╰",
          right_arrow = ">",
        },
        textobject = "",
        max_file_size = 1024 * 1024,
        error_sign = true,
        duration = 200,
        delay = 300,
      },

      indent = {
        enable = true,
        priority = 10,
        style = {
          "#1f2335",
          "#292e42",
        },
        use_treesitter = false,
        chars = {
          "│",
        },
        ahead_lines = 5,
        delay = 100,
      },

      line_num = {
        enable = true,
        priority = 10,
        style = "#bb9af7",
        use_treesitter = false,
      },

      blank = {
        enable = false,
        priority = 9,
        chars = {
          "․",
        },
        style = {
          { fg = "#3b4261" },
        },
      },
    })
  end,
}
