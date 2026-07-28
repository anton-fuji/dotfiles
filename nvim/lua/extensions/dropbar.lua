return {
  "Bekaboo/dropbar.nvim",
  event = "BufReadPre",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "nvim-telescope/telescope-fzf-native.nvim",
  },
  config = function()
    local dropbar = require("dropbar.api")

    require("dropbar").setup({
      bar = {
        padding = { left = 1, right = 1 },
      },
    })

    vim.keymap.set("n", "<leader>;", dropbar.pick, { desc = "Pick symbol in winbar" })
    vim.keymap.set("n", "[;", dropbar.goto_context_start, { desc = "Go to context start" })
    vim.keymap.set("n", "];", dropbar.select_next_context, { desc = "Select next context" })
  end,
}
