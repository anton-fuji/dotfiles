return {
  "rmagatti/auto-session",
  lazy = false,
  opts = {
    auto_restore_last_session = false,
    args_allow_files_auto_save = true,
    git_use_branch_name = true,
    suppressed_dirs = { "~", "~/Downloads", "/" },
    bypass_save_filetypes = {
      "alpha",
      "dashboard",
      "lazy",
      "mason",
      "NvimTree",
      "TelescopePrompt",
    },
    session_lens = {
      picker = "telescope",
      previewer = "summary",
    },
  },
  keys = {
    { "<leader>ps", "<cmd>AutoSession search<cr>", desc = "Search sessions" },
    { "<leader>pS", "<cmd>AutoSession save<cr>", desc = "Save session" },
    { "<leader>pt", "<cmd>AutoSession toggle<cr>", desc = "Toggle session autosave" },
  },
}
