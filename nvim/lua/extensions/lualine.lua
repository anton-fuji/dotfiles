local colors = {
  bg = "#0f1117",
  surface = "#161821",
  surface_alt = "#1e2132",
  fg = "#9a9ca5",
  muted = "#6b7089",
  cyan = "#89b8c2",
  blue = "#84a0c6",
  purple = "#a093c7",
  green = "#8bbf9f",
  yellow = "#d9a576",
  red = "#cc7a8b",
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

-- LSPクライアント表示
local function lsp_client()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then
    return "No LSP"
  end
  local client_names = {}
  for _, client in ipairs(clients) do
    table.insert(client_names, client.name)
  end
  return "󰒋 " .. table.concat(client_names, ", ")
end

-- buffer tub ( active / inactive )
local mode_colors = {
  n = colors.blue,
  i = colors.cyan,
  v = colors.purple,
  V = colors.purple,
  ["\22"] = colors.purple,
  c = colors.yellow,
  R = colors.red,
  s = colors.yellow,
  S = colors.yellow,
  ["\19"] = colors.yellow,
  t = colors.green,
}

local function mode_color()
  return { fg = colors.bg, bg = mode_colors[vim.fn.mode()] or colors.blue, gui = "bold" }
end

local function project_name()
  return "󰉋 " .. vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
end

local function recording_macro()
  local register = vim.fn.reg_recording()
  if register == "" then
    return ""
  end
  return "󰑋 REC @" .. register
end

local function task_status()
  local ok, task_list = pcall(require, "overseer.task_list")
  if not ok then
    return ""
  end

  local running, failed = 0, 0
  for _, task in ipairs(task_list.list_tasks({})) do
    if task.status == "RUNNING" then
      running = running + 1
    elseif task.status == "FAILURE" then
      failed = failed + 1
    end
  end

  local status = {}
  if running > 0 then
    table.insert(status, "󰑮 " .. running)
  end
  if failed > 0 then
    table.insert(status, "󰅚 " .. failed)
  end
  return table.concat(status, " ")
end

require("lualine").setup({
  options = {
    theme = {
      normal = {
        a = { fg = colors.bg, bg = colors.blue, gui = "bold" },
        b = { fg = colors.fg, bg = colors.surface_alt },
        c = { fg = colors.fg, bg = colors.surface },
      },
      inactive = {
        a = { fg = colors.muted, bg = colors.bg },
        b = { fg = colors.muted, bg = colors.bg },
        c = { fg = colors.muted, bg = colors.bg },
      },
    },
    icons_enabled = true,
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
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
      {
        "mode",
        fmt = function(mode)
          return " " .. mode:upper() .. " "
        end,
        color = mode_color,
        padding = { left = 1, right = 1 },
      },
    },
    lualine_b = {
      {
        project_name,
        color = { fg = colors.cyan, gui = "bold" },
        padding = { left = 2, right = 1 },
      },
      {
        "branch",
        icon = " ",
        color = { fg = colors.purple, gui = "bold" },
        padding = { left = 2, right = 1 },
      },
      {
        "diff",
        source = diff_source,
        symbols = { added = " ", modified = "󰁨 ", removed = " " },
        diff_color = {
          added = { fg = colors.green },
          modified = { fg = colors.blue },
          removed = { fg = "#f78c6c" },
        },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_c = {
      {
        "filetype",
        colored = true,
        icon_only = true,
        color = { fg = colors.fg },
        padding = { left = 2, right = 1 },
      },
      {
        "filename",
        file_status = true,
        newfile_status = true,
        path = 1,
        shorting_target = 40,
        symbols = { modified = "_󰷥", readonly = " ", newfile = "󱃋", unnamed = "[No Name]" },
        padding = { left = 1, right = 2 },
        color = { fg = colors.fg, gui = "bold" },
      },
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
        update_in_insert = true,
        padding = { left = 2, right = 2 },
      },
      {
        "searchcount",
        maxcount = 999,
        timeout = 200,
        icon = "󰍉 ",
        color = { fg = colors.yellow },
        padding = { left = 1, right = 1 },
      },
      {
        "selectioncount",
        icon = "󰒅 ",
        color = { fg = colors.purple },
        padding = { left = 1, right = 1 },
      },
    },
    lualine_x = {
      {
        recording_macro,
        cond = function()
          return vim.fn.reg_recording() ~= ""
        end,
        color = { fg = colors.bg, bg = colors.red, gui = "bold" },
        padding = { left = 1, right = 1 },
      },
      {
        task_status,
        cond = function()
          return task_status() ~= ""
        end,
        color = { fg = colors.yellow, gui = "bold" },
        on_click = function()
          vim.cmd("OverseerToggle")
        end,
        padding = { left = 1, right = 1 },
      },
      {
        lsp_client,
        icon = "",
        color = { fg = colors.cyan, gui = "bold" },
        padding = { left = 1, right = 1 },
      },
      {
        "location",
        icon = "󰍎",
        padding = { left = 2, right = 1 },
      },
    },
    lualine_y = {
      {
        "progress",
        color = { fg = colors.muted },
        padding = { left = 1, right = 2 },
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
        color = { bg = colors.blue, fg = colors.bg, gui = "bold" },
        padding = { left = 2, right = 2 },
      },
    },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {
      "filename",
      padding = { left = 2, right = 2 },
    },
    lualine_x = {
      "location",
      padding = { left = 2, right = 2 },
    },
    lualine_y = {},
    lualine_z = {},
  },

  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { "lazy", "mason" },
})
