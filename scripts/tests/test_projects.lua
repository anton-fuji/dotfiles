-- Run from the dotfiles root: lua scripts/tests/test_projects.lua
local selected, activated, spawned, title
local existing = {
  get_title = function() return "project:/home/test/repos/zebra" end,
  activate = function() activated = true end,
}
local mux = {
  tabs = function() return { existing } end,
  spawn_tab = function(_, args)
    spawned = args
    return { set_title = function(_, value) title = value end }
  end,
}
local window = {
  mux_window = function() return mux end,
  perform_action = function(_, action) selected = action end,
  toast_notification = function() error("unexpected notification") end,
}
package.loaded.wezterm = {
  home_dir = "/home/test",
  config_dir = "/config/wezterm",
  column_width = function(s) return #s end,
  format = function(items)
    local text = {}
    for _, item in ipairs(items) do
      if type(item) == "table" and item.Text then table.insert(text, item.Text) end
    end
    return table.concat(text)
  end,
  run_child_process = function()
    return true, "/home/test/repos/alpha\n/home/test/repos/zebra\n/home/test/repos/alpha\n/home/testing/alpha\n", ""
  end,
  action = { InputSelector = function(value) return value end },
  action_callback = function(callback) return callback end,
}
local projects = dofile("wezterm/projects.lua")
projects.select(window, {})
assert(#selected.choices == 3, "deduplicate paths")
assert(selected.choices[1].id == "/home/test/repos/zebra", "open projects first")
assert(selected.choices[1].label:find("● open", 1, true))
assert(selected.choices[2].label:find("~/repos", 1, true))
assert(selected.choices[3].label:find("/home/testing", 1, true), "home prefix must match a directory")
selected.action(window, {}, nil)
assert(not activated and not spawned, "cancel must be a no-op")
selected.action(window, {}, selected.choices[1].id)
assert(activated and not spawned, "reuse open tab")
selected.action(window, {}, "/home/test/repos/space ' project")
assert(spawned.cwd == "/home/test/repos/space ' project")
assert(spawned.args[#spawned.args] == spawned.cwd, "path remains a separate argument")
assert(title == "project:" .. spawned.cwd)
print("PASS: project ordering, labels, deduplication, cancellation, reuse and path routing")
