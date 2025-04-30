return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup {
        sort_by = "name",
        view = { width = 30, side = "left" },
        renderer = { highlight_git = true, icons = { show = { git = true } } },
        filters = { dotfiles = false },
    }
        vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>", { silent = true, desc = "Toggle NvimTree" })
        vim.keymap.set("n", "<leader>r", ":NvimTreeRefresh<CR>", { silent = true, desc = "Refresh NvimTree" })
        vim.keymap.set("n", "<leader>n", ":NvimTreeFindFile<CR>", { silent = true, desc = "Find File in NvimTree" })
    end,
}  