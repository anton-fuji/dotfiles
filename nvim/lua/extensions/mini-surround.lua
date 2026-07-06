return {
  "echasnovski/mini.surround",
  version = "*",
  event = "VeryLazy",
  keys = {
    { "gsa", mode = { "n", "x" }, desc = "Add surrounding" },
    { "gsd", mode = "n", desc = "Delete surrounding" },
    { "gsr", mode = "n", desc = "Replace surrounding" },
    { "gsf", mode = "n", desc = "Find surrounding" },
    { "gsF", mode = "n", desc = "Find left surrounding" },
    { "gsh", mode = "n", desc = "Highlight surrounding" },
    { "gsn", mode = "n", desc = "Update surround search lines" },
  },
  config = function()
    require("mini.surround").setup({
      mappings = {
        add = "gsa",            -- Add surrounding
        delete = "gsd",         -- Delete surrounding
        replace = "gsr",        -- Replace surrounding
        find = "gsf",           -- Find surrounding
        find_left = "gsF",      -- Find surrounding to the left
        highlight = "gsh",      -- Highlight surrounding
        update_n_lines = "gsn", -- Update n_lines
      },
      n_lines = 20,            -- 何行先まで探すか
      search_method = "cover_or_next",
    })
  end,
}
