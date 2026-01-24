return {
  "echasnovski/mini.surround",
  version = "*",
  event = "VeryLazy",
  config = function()
    require("mini.surround").setup({
      mappings = {
        add = "sa",            -- Add surrounding
        delete = "sd",         -- Delete surrounding
        replace = "sr",        -- Replace surrounding
        find = "sf",           -- Find surrounding
        find_left = "sF",      -- Find surrounding to the left
        highlight = "sh",      -- Highlight surrounding
        update_n_lines = "sn", -- Update n_lines
      },
      n_lines = 20,            -- 何行先まで探すか
      search_method = "cover_or_next",
    })
  end,
}
