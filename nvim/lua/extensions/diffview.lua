return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewFileHistory",
    "DiffviewToggleFiles",
  },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Open Git diff view" },
    { "<leader>gD", "<cmd>DiffviewClose<cr>", desc = "Close Git diff view" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Current file Git history" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { layout = "diff2_horizontal" },
      merge_tool = { layout = "diff3_horizontal" },
      file_history = { layout = "diff2_horizontal" },
    },
    file_panel = {
      listing_style = "tree",
      tree_options = { flatten_dirs = true },
      win_config = { position = "left", width = 35 },
    },
  },
}
