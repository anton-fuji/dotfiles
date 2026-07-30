return {
  "stevearc/overseer.nvim",
  cmd = { "OverseerRun", "OverseerOpen", "OverseerToggle", "OverseerRestartLast" },
  keys = {
    {
      "<leader>or",
      function() require("utils.project").run_task() end,
      desc = "Run project task",
    },
    { "<leader>ot", "<cmd>OverseerOpen<cr>", desc = "Focus task list" },
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
