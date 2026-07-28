return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<Tab>",      "<Cmd>BufferLineCycleNext<CR>", desc = "Next Tab" },
    { "<S-Tab>",    "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Tab" },
    { "<leader>bd", "<Cmd>bdelete<CR>",             desc = "close current bufferline" },
    { "<leader>bj", "<Cmd>BufferLinePick<CR>",      desc = "Buffer line pick" },
  },
  opts = {
    highlights = {
      fill = { bg = "#16161e" },
      background = { bg = "#16161e", fg = "#565f89" },
      buffer_selected = { bg = "#1a1b26", fg = "#c0caf5", bold = true },
      indicator_selected = { fg = "#7aa2f7", bg = "#1a1b26" },
      separator = { fg = "#16161e", bg = "#16161e" },
      separator_selected = { fg = "#16161e", bg = "#1a1b26" },
      modified_selected = { fg = "#7dcfff", bg = "#1a1b26" },
    },
    options = {
      mode = "buffers",
      -- separator_style = "slope",
      separator_style = "thin",
      hover = { enabled = true, delay = 200 },
      show_buffer_close_icons = false,
      show_close_icon = false,
      modified_icon = "●",
      diagnostics = "nvim_lsp",
      diagnostics_indicator = function(count, level, is_visible)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      custom_filter = function(buf_number)
        local buf_name = vim.api.nvim_buf_get_name(buf_number)
        return buf_name ~= "" and vim.bo[buf_number].buftype ~= "terminal"
      end,
    },
  },
}
