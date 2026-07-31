return {
  "j-hui/fidget.nvim",
  event = "LspAttach",
  opts = {
    progress = {
      suppress_on_insert = true,
      display = {
        render_limit = 1,
        done_ttl = 1,
        done_icon = "󰄬",
        progress_icon = { "dots" },
        progress_style = "DiagnosticInfo",
        group_style = "Title",
      },
    },
    notification = {
      override_vim_notify = false,
      window = {
        normal_hl = "NormalFloat",
        winblend = 45,
        border = "none",
        max_width = 32,
        x_padding = 0,
        y_padding = 0,
      },
    },
  },
}
