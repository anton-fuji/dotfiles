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
      },
    },
}
  