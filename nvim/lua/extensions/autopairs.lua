return {
    {
      "windwp/nvim-autopairs",
      event = { "BufNewFile", "BufReadPre" },
      config = function()
        require("nvim-autopairs").setup({
          check_ts = true,
        })
      end,
    }
}