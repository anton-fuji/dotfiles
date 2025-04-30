-- General settings for Lazy
require('lazy').setup({
    -- tokyonight
    "folke/tokyonight.nvim",

    -- nvim-web-devicons
    'nvim-tree/nvim-web-devicons',

    -- nvim-tree
    {
        'nvim-tree/nvim-tree.lua',
        dependencies = {'nvim-tree/nvim-web-devicons'}
    },
})

