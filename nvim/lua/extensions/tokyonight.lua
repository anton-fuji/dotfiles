return {
  "folke/tokyonight.nvim",
  lazy = false,
  config = function()
    require("tokyonight").setup {
      -- A deep navy foundation with TokyoNight's brighter blue accents.
      style = "storm",
      -- Keep the editor glass-like so WezTerm's background transparency shows through.
      transparent = true,
      terminal_colors = true,
      dim_inactive = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
      on_highlights = function(hl, c)
        hl.CursorLine = { bg = "#1a2238" }
        hl.ColorColumn = { bg = "#1a2238" }
        hl.LineNr = { fg = "#3b4261" }
        hl.CursorLineNr = { fg = c.blue, bold = true }
        hl.Visual = { bg = "#33467c" }
        hl.Pmenu = { bg = "#161b2c", fg = c.fg }
        hl.PmenuSel = { bg = "#283457", fg = c.fg, bold = true }
        hl.FloatBorder = { fg = "#3d59a1", bg = "#161b2c" }
        hl.NormalFloat = { bg = "#161b2c" }
        hl.WinSeparator = { fg = "#283457" }
      end,
    }
    vim.cmd("colorscheme tokyonight")
  end,
}
