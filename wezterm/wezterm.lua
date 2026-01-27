local wezterm = require("wezterm")
local background = require("background")
local transparency = require("transparency")

local config = wezterm.config_builder()
local act = wezterm.action

config.automatically_reload_config = true
config.font_size = 13.7
config.use_ime = true
config.window_background_opacity = 0.55
config.macos_window_background_blur = 20
config.background = background

-- ウィンドウサイズ
config.initial_rows = 90
config.initial_cols = 220

----------------------------------------------------
-- Tab
----------------------------------------------------
-- タイトルバーを非表示
config.window_decorations = "RESIZE"
-- タブバーの表示
config.show_tabs_in_tab_bar = true
config.tab_bar_at_bottom = true
-- タブが一つの時は非表示
config.hide_tab_bar_if_only_one_tab = true
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
  inactive_titlebar_bg = "none",
  active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
  colors = { "#0a0a0a" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブ同士の境界線を非表示
config.colors = {
  tab_bar = {
    inactive_tab_edge = "none",
  },

  cursor_bg = "#F1009A",
}

-- タブの形をカスタマイズ
-- タブの左側の装飾
local SOLID_LEFT_ARROW = wezterm.nerdfonts.ple_lower_right_triangle
-- タブの右側の装飾
local SOLID_RIGHT_ARROW = wezterm.nerdfonts.ple_upper_left_triangle

wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
  local background = "#00152B"
  local foreground = "#FFFFFF"
  local edge_background = "none"
  if tab.is_active then
    background = "#175DAF"
    foreground = "#FFFFFF"
  end
  local edge_foreground = background
  local title = "   " .. wezterm.truncate_right(tab.active_pane.title, max_width - 1) .. "   "
  return {
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_LEFT_ARROW },
    { Background = { Color = background } },
    { Foreground = { Color = foreground } },
    { Text = title },
    { Background = { Color = edge_background } },
    { Foreground = { Color = edge_foreground } },
    { Text = SOLID_RIGHT_ARROW },
  }
end)

----------------------------------------------------
-- Keybindings & CopyMode
----------------------------------------------------
config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

local keys = require("keybinds").keys or {}
local key_tables = require("keybinds").key_tables or {}

table.insert(keys, {
  key = 'X',
  mods = 'CTRL|SHIFT',
  action = act.ActivateCopyMode,
})
table.insert(keys, transparency.key)

-- CopyMode
key_tables.copy_mode = {
  { key = 'Escape', mods = 'NONE',  action = act.CopyMode 'Close' },
  { key = 'q',      mods = 'NONE',  action = act.CopyMode 'Close' },

  { key = 'h',      mods = 'NONE',  action = act.CopyMode 'MoveLeft' },
  { key = 'j',      mods = 'NONE',  action = act.CopyMode 'MoveDown' },
  { key = 'k',      mods = 'NONE',  action = act.CopyMode 'MoveUp' },
  { key = 'l',      mods = 'NONE',  action = act.CopyMode 'MoveRight' },
  { key = 'w',      mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
  { key = 'b',      mods = 'NONE',  action = act.CopyMode 'MoveBackwardWord' },
  { key = 'e',      mods = 'NONE',  action = act.CopyMode 'MoveForwardWordEnd' },
  { key = '0',      mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine' },
  { key = '$',      mods = 'NONE',  action = act.CopyMode 'MoveToEndOfLineContent' },
  { key = '^',      mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLineContent' },
  { key = 'g',      mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackTop' },
  { key = 'G',      mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
  { key = 'd',      mods = 'CTRL',  action = act.CopyMode { MoveByPage = 0.5 } },
  { key = 'u',      mods = 'CTRL',  action = act.CopyMode { MoveByPage = -0.5 } },
  { key = 'v',      mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
  { key = 'V',      mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Line' } },
  { key = 'v',      mods = 'CTRL',  action = act.CopyMode { SetSelectionMode = 'Block' } },

  {
    key = 'y',
    mods = 'NONE',
    action = act.Multiple {
      { CopyTo = 'ClipboardAndPrimarySelection' },
      { CopyMode = 'Close' },
    }
  },
  { key = 'Enter', mods = 'NONE', action = act.CopyMode 'ClearSelectionMode' },
}

config.keys = keys
config.key_tables = key_tables

return config
