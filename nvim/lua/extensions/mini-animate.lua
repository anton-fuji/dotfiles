return {
  "echasnovski/mini.animate",
  event = "VeryLazy",
  config = function()
    if not vim.g.vscode then
      local animate = require("mini.animate")
      animate.setup({
        cursor = {
          enable = false,
        },
        scroll = {
          enable = true,
          timing = animate.gen_timing.exponential({
            easing = "out",
            duration = 200,
            unit = "total",
          }),
        },
        resize = { enable = false },
        open = { enable = false },
        close = { enable = false },
      })
    end
  end,
}
