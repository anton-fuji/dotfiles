return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerToggle", "OverseerRestartLast" },
  keys = {
    { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Run project task" },
    { "<leader>ot", "<cmd>OverseerToggle<cr>", desc = "Toggle task list" },
    { "<leader>oR", "<cmd>OverseerRestartLast<cr>", desc = "Restart last task" },
  },
  opts = {
    task_list = {
      direction = "bottom",
      min_height = 12,
      max_height = 20,
      default_detail = 1,
    },
    form = {
      win_opts = { winblend = 12 },
    },
  },
}
