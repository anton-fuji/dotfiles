local wezterm = require("wezterm")
local M = {}

-- Keep the full path as the selection ID; presentation never affects routing.
local function project_choices(window, stdout)
  local opened = {}
  for _, tab in ipairs(window:mux_window():tabs()) do
    local path = tab:get_title():match("^project:(.+)")
    if path then
      opened[path] = true
    end
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
      table.insert(entries, { path = path, name = name, parent = parent, opened = opened[path] or false })
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
    action = wezterm.action_callback(function(win, _, path)
      if not path then
        return
      end
      local title = "project:" .. path
      for _, tab in ipairs(win:mux_window():tabs()) do
        if tab:get_title() == title then
          tab:activate()
          return
        end
      end
      local tab = win:mux_window():spawn_tab({
        cwd = path,
        args = { "/bin/zsh", "-lc", 'exec python3 "$1" project "$2"', "worktree-launch",
          wezterm.config_dir .. "/../scripts/worktree", path },
      })
      tab:set_title(title)
    end),
  }), pane)
end

return M
