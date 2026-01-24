return {
  "kevinhwang91/nvim-hlslens",
  event = "VeryLazy",
  config = function()
    require("hlslens").setup({
      calm_down = true,
      nearest_only = false,
    })

    vim.keymap.set("n", "n", "<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>")
    vim.keymap.set("n", "N", "<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>")
    vim.keymap.set("n", "*", "*<Cmd>lua require('hlslens').start()<CR>")
  end,
}
