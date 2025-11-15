return {
  "echasnovski/mini.animate",
  event = "VeryLazy",
  config = function()
    if not vim.g.vscode then
      local animate = require("mini.animate")
      animate.setup({
        cursor = {
          timing = animate.gen_timing.exponential({
            easing = "out",
            duration = 100,
            unit = "total",
          }),
          path = animate.gen_path.angle({
            predicate = function() return true end,
          }),
        },
        scroll = {
          enable = true,
          timing = animate.gen_timing.exponential({
            easing = "out",
            duration = 200,
            unit = "total",
          }),
          subscroll = nil,
        },
        resize = { enable = false },
        open = { enable = true },
        close = { enable = false },
      })
    end
  end,
}
