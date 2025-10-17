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
          subscroll = animate.gen_subscroll.equal({
            predicate = function(total_scroll)
              return math.abs(total_scroll) > 1
            end,
          }),
        },
        resize = { enable = false },
        open = { enable = true },
        close = { enable = false },
      })
    end
  end,
}
