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
      fill = { bg = "#0f1117" },
      background = { bg = "#0f1117", fg = "#6b7089" },
      buffer_selected = { bg = "#161821", fg = "#d4d9e1", bold = true },
      indicator_selected = { fg = "#84a0c6", bg = "#161821" },
      separator = { fg = "#0f1117", bg = "#0f1117" },
      separator_selected = { fg = "#0f1117", bg = "#161821" },
      modified = { fg = "#84a0c6", bg = "#0f1117" },
      modified_visible = { fg = "#84a0c6", bg = "#0f1117" },
      modified_selected = { fg = "#84a0c6", bg = "#161821" },
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
