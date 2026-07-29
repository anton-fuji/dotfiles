return {
  "folke/tokyonight.nvim",
  lazy = false,
  config = function()
    require("tokyonight").setup {
      -- Keep TokyoNight's syntax clarity, with Iceberg Dark's muted UI surfaces.
      style = "storm",
      -- Keep the editor glass-like so WezTerm's background transparency shows through.
      transparent = true,
      terminal_colors = true,
      dim_inactive = true,
      styles = {
        comments = { italic = true },
        keywords = { italic = true },
      },
      on_highlights = function(hl)
        hl.CursorLine = { bg = "#1e2132" }
        hl.ColorColumn = { bg = "#1e2132" }
        hl.LineNr = { fg = "#3e445e" }
        hl.CursorLineNr = { fg = "#84a0c6", bold = true }
        hl.Visual = { bg = "#30364a" }
        hl.Pmenu = { bg = "#161821", fg = "#9a9ca5" }
        hl.PmenuSel = { bg = "#30364a", fg = "#d4d9e1", bold = true }
        hl.FloatBorder = { fg = "#3e445e", bg = "#161821" }
        hl.NormalFloat = { bg = "#161821" }
        hl.WinSeparator = { fg = "#3e445e" }

        -- Iceberg Dark-inspired syntax palette, while retaining TokyoNight's contrast.
        hl.Comment = { fg = "#6b7089", italic = true }
        hl.Keyword = { fg = "#84a0c6" }
        hl.Statement = { fg = "#84a0c6" }
        hl.Function = { fg = "#84a0c6" }
        hl.Identifier = { fg = "#89b8c2" }
        hl.Type = { fg = "#84a0c6" }
        hl.String = { fg = "#89b8c2" }
        hl.Constant = { fg = "#a093c7" }
        hl.Number = { fg = "#a093c7" }
        hl.Operator = { fg = "#84a0c6" }
        hl.PreProc = { fg = "#b4be82" }
        hl["@comment"] = { link = "Comment" }
        hl["@keyword"] = { link = "Keyword" }
        hl["@keyword.function"] = { link = "Keyword" }
        hl["@function"] = { link = "Function" }
        hl["@function.call"] = { link = "Function" }
        hl["@type"] = { link = "Type" }
        hl["@type.builtin"] = { link = "Type" }
        hl["@string"] = { link = "String" }
        hl["@number"] = { link = "Number" }
        hl["@constant"] = { link = "Constant" }
        hl["@operator"] = { link = "Operator" }
        hl["@variable"] = { link = "Identifier" }
        hl["@attribute"] = { link = "PreProc" }
      end,
    }
    vim.cmd("colorscheme tokyonight")
  end,
}
