local fb_actions = require("telescope").extensions.file_browser.actions

require("telescope").setup({
  defaults = {
    mappings = {
      i = {
        -- ["<C-h>"] = "which_key",
        ["<esc>"] = require("telescope.actions").close,
        ["<C-[>"] = require("telescope.actions").close,
        ["<C-j>"] = require("telescope.actions").move_selection_next,
        ["<C-k>"] = require("telescope.actions").move_selection_previous,
        ["<C-u>"] = false,
        ["<C-d>"] = false,
      },
      n = {
        -- ["<C-h>"] = "which_key",
        ["q"] = require("telescope.actions").close,
      },
    },
    winblend = 20,
    path_display = { "truncate" },
    sorting_strategy = "ascending",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = {
        prompt_position = "top",
        preview_width = 0.55,
      },
      vertical = {
        mirror = false,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    file_browser = {
      theme = "dropdown",
      hijack_netrw = true,
      mappings = {
        ["i"] = {
          ["<C-w>"] = function()
            vim.cmd("normal vbd")
          end,
        },
        ["n"] = {
          ["N"] = fb_actions.create,
          ["h"] = fb_actions.goto_parent_dir,
          ["/"] = function()
            vim.cmd("startinsert")
          end,
        },
      },
    },
    project = {
      base_dirs = {
        { path = "~/work/workspace", max_depth = 2 },
        { path = "~/.config/nvim",   max_depth = 2 },
      },
      hidden_files = true,
      theme = "dropdown",
    },
  },
})
