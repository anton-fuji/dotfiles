local colors = {
    bg = "#011627",
    fg = "#c3ccdc",
    green = "#7fdbca",
    blue = "#82aaff",
    purple = "#c792ea",
    black = "#1f2430",
  }
  
  -- Inform. git diff
  local function diff_source()
    local gs = vim.b.gitsigns_status_dict
    if gs then
      return {
        added = gs.added,
        modified = gs.changed,
        removed = gs.removed,
      }
    end
  end
  
  -- buffer tub ( active / inactive )
  local switch_color = {
    active = { fg = colors.bg, bg = colors.green },
    inactive = { fg = colors.fg, bg = colors.black },
  }
  
  require("lualine").setup({
    options = {
      theme = "nightfly",
      icons_enabled = true,
      component_separators = { left = "", right = "" },
      section_separators = { left = "", right = "" },
      disabled_filetypes = {
        statusline = {},
        winbar = {},
      },
      ignore_focus = {},
      always_divide_middle = true,
      globalstatus = true,
      refresh = {
        statusline = 1000,
        tabline = 1000,
        winbar = 1000,
      },
    },
    sections = {
      lualine_a = {
        { "mode" },
      },
      lualine_b = {
        {
          "filetype",
          colored = true,
          icon_only = true,
          color = { fg = colors.fg },
          padding = { left = 1, right = 0 },
        },
        {
          "filename",
          file_status = true,
          newfile_status = true,
          path = 1,
          shorting_target = 40,
          symbols = { modified = "_󰷥", readonly = " ", newfile = "󱃋", unnamed = "[No Name]" },
        },
      },
      lualine_c = {
        {
          "diagnostics",
          sources = { "nvim_diagnostic", "nvim_lsp" },
          sections = { "error", "warn", "info", "hint" },
          symbols = {
            error = " ",
            warn = " ",
            info = " ",
            hint = " ",
          },
          colored = true,
          always_visible = false,
          update_in_insert = false,
          padding = { left = 1, right = 1 },
        },
      },
      lualine_x = {
        {
          "location",
          padding = { left = 1, right = 0 },
        },
      },
      lualine_y = {
        {
          "progress",
          padding = { left = 0, right = 1 },
        },
      },
      lualine_z = {
        {
          "fileformat",
          icons_enabled = true,
          symbols = {
            unix = "", -- f17c
            dos = "", -- e70f
            mac = "", -- e711
          },
          --
          color = { bg = colors.green, fg = colors.bg },
          padding = { left = 1, right = 1 },
        },
      },
    },
  
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { "filename" },
      lualine_x = { "location" },
      lualine_y = {},
      lualine_z = {},
    },
  
    tabline = {},
    winbar = {},
    inactive_winbar = {},
    extensions = { "lazy", "mason" },
  })
