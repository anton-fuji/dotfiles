return {
  "akinsho/bufferline.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  event = "VeryLazy",
  keys = {
    { "<Tab>",      "<Cmd>BufferLineCycleNext<CR>", desc = "Next Tab" },
    { "<S-Tab>",    "<Cmd>BufferLineCyclePrev<CR>", desc = "Prev Tab" },
    { "<leader>bd", "<Cmd>bdelete<CR>",             desc = "close current bufferline" },
  },
  opts = {
    options = {
      mode = "buffers",
      separator_style = "slope",
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
