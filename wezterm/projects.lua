local wezterm = require("wezterm")
local M = {}

-- Keep the full path as the selection ID; presentation never affects routing.
local function path_contains(root, path)
  root = root:gsub("/+$", "")
  path = path:gsub("/+$", "")
  return path == root or path:sub(1, #root + 1) == root .. "/"
end

local function pane_path(pane)
  local ok, cwd = pcall(function() return pane:get_current_working_dir() end)
  if not ok or not cwd then return nil end
  if type(cwd) == "userdata" or type(cwd) == "table" then
    return cwd.file_path
  end
  if type(cwd) == "string" then
    local path = cwd:match("^file://[^/]*(/.*)$") or cwd
    return path:gsub("%%(%x%x)", function(hex) return string.char(tonumber(hex, 16)) end)
  end
  return nil
end

local function tab_project_path(tab)
  local title = tab:get_title()
  local project = title and title:match("^project:(.+)$")
  if project then return project end
  if type(tab.panes) ~= "function" then return nil end
  for _, pane in ipairs(tab:panes()) do
    local path = pane_path(pane)
    if path then return path end
  end
  return nil
end

local function project_choices(window, stdout)
  local opened = {}
  for _, tab in ipairs(window:mux_window():tabs()) do
    local path = tab_project_path(tab)
    if path then table.insert(opened, path) end
  end
  local entries, seen = {}, {}
  local name_width = 0
  for path in stdout:gmatch("[^\r\n]+") do
    if not seen[path] then
      seen[path] = true
      local name = path:match("([^/]+)$") or path
      local parent = path:match("^(.*)/[^/]+$") or ""
      if parent == wezterm.home_dir then
        parent = "~"
      elseif parent:sub(1, #wezterm.home_dir + 1) == wezterm.home_dir .. "/" then
        parent = "~" .. parent:sub(#wezterm.home_dir + 1)
      end
      name_width = math.max(name_width, wezterm.column_width(name))
      local is_open = false
      for _, open_path in ipairs(opened) do
        if path_contains(path, open_path) then
          is_open = true
          break
        end
      end
      table.insert(entries, { path = path, name = name, parent = parent, opened = is_open })
    end
  end
  table.sort(entries, function(a, b)
    if a.opened ~= b.opened then
      return a.opened
    end
    if a.name:lower() ~= b.name:lower() then
      return a.name:lower() < b.name:lower()
    end
    return a.path < b.path
  end)
  local choices = {}
  for _, entry in ipairs(entries) do
    table.insert(choices, {
      id = entry.path,
      label = wezterm.format({
        { Foreground = { Color = entry.opened and "#BB9AF7" or "#8FBFBB" } },
        { Text = entry.opened and "  ● open  " or "  ○       " },
        { Foreground = { Color = "#B7E3E0" } },
        { Attribute = { Intensity = "Bold" } },
        { Text = entry.name },
        { Attribute = { Intensity = "Normal" } },
        { Text = string.rep(" ", name_width - wezterm.column_width(entry.name) + 3) },
        { Foreground = { Color = "#8BA4BF" } },
        { Text = entry.parent },
        "ResetAttributes",
      }),
    })
  end
  return choices
end

function M.select(window, pane)
  local ok, stdout, stderr = wezterm.run_child_process({ "/bin/zsh", "-lc", "exec ghq list -p" })
  if not ok then
    window:toast_notification("Projects", "ghq list failed: " .. stderr, nil, 6000)
    return
  end
  local choices = project_choices(window, stdout)
  if #choices == 0 then
    window:toast_notification("Projects", "ghq管理のリポジトリがありません。ghq getで追加してください。", nil, 6000)
    return
  end
  window:perform_action(wezterm.action.InputSelector({
    title = "Projects",
    fuzzy = true,
    description = "Enter: open / switch   Esc: cancel   /: search",
    fuzzy_description = "Search projects  (↑↓ select · Enter open · Esc cancel): ",
    choices = choices,
    action = wezterm.action_callback(function(win, callback_pane, path)
      if not path then
        return
      end
      local title = "project:" .. path
      local mux_window = win:mux_window()
      local function activate_project_tab()
        for index, tab in ipairs(mux_window:tabs()) do
          local current_path = tab_project_path(tab)
          if current_path and path_contains(path, current_path) then
            tab:set_title(title)
            if type(tab.activate) == "function" then
              tab:activate()
            else
              win:perform_action(wezterm.action.ActivateTab(index - 1), callback_pane)
            end
            return true
          end
        end
        return false
      end

      if activate_project_tab() then
        return
      end

      local tab = mux_window:spawn_tab({
        cwd = path,
        args = { "/bin/zsh", "-lc", 'exec python3 "$1" project "$2"', "worktree-launch",
          wezterm.config_dir .. "/../scripts/worktree", path },
      })
      tab:set_title(title)
      if type(tab.activate) == "function" then
        tab:activate()
      else
        win:perform_action(wezterm.action.ActivateTab(#mux_window:tabs() - 1), callback_pane)
      end
    end),
  }), pane)
end

return M
