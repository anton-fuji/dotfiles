return {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown", "rmd", "md" },
    render_modes = { 'n', 'c', 't' },
    opts = {
      heading = { sign = false },
      checkbox = { enabled = false },
    },
}
  