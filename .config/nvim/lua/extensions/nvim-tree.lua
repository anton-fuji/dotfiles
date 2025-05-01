return {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = { "NvimTreeToggle", "NvimTreeFindFile", "NvimTreeRefresh" },
    keys = {
      { "<C-n>",    "<cmd>NvimTreeToggle<CR>",    desc = "Toggle NvimTree" },
      { "<leader>r","<cmd>NvimTreeRefresh<CR>",   desc = "Refresh NvimTree" },
      { "<leader>n","<cmd>NvimTreeFindFile<CR>",  desc = "Find File in NvimTree" },
    },
    config = function()
      require("nvim-tree").setup {
        sort_by = "name",
        view = {
          width = 30,
          side  = "left",
        },
        renderer = {
          highlight_git = true,
          icons = {
            show = {
              git    = true,
              folder = true,
              file   = true,
            },
          },
        },
        filters = {
          dotfiles = false,
        },
        update_focused_file = {
          enable     = true,
          update_cwd = true,
        },
        git = {
          enable = true,
          ignore = true,
        },
      }
    end,
  }
  
  