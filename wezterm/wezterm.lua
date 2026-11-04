local wezterm = require("wezterm")
local background = require("background")
local transparency = require("transparency")

local config = wezterm.config_builder()
local act = wezterm.action
local terminal_colors = wezterm.color.get_default_colors()

-- Tokyo NightのANSIパレット。Lazygitのステータス表示にも使われる。
-- get_default_colors()をベースにして、背景などの既存設定は維持する。
terminal_colors.ansi[1] = "#15161E"
terminal_colors.ansi[2] = "#F7768E"
terminal_colors.ansi[3] = "#9ECE6A"
terminal_colors.ansi[4] = "#E0AF68"
terminal_colors.ansi[5] = "#7AA2F7"
terminal_colors.ansi[6] = "#BB9AF7"
terminal_colors.ansi[7] = "#7DCFFF"
terminal_colors.ansi[8] = "#A9B1D6"

terminal_colors.brights[1] = "#414868"
terminal_colors.brights[2] = "#FF899D"
terminal_colors.brights[3] = "#9FE044"
terminal_colors.brights[4] = "#FABA4A"
terminal_colors.brights[5] = "#8DB0FF"
terminal_colors.brights[6] = "#C7A9FF"
terminal_colors.brights[7] = "#A4DAFF"
terminal_colors.brights[8] = "#C0CAF5"

config.automatically_reload_config = true
config.font_size = 13.7
config.use_ime = true
config.window_background_opacity = 0.55
config.macos_window_background_blur = 20
config.background = background

-- 新規タブ・ペインでGopherの衝突アニメーションを一度再生し、Fastfetchへ渡す
config.default_prog = { "/bin/sh", wezterm.home_dir .. "/.config/wezterm/gopher-startup.sh" }

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
-- タブが一つの時も、プロジェクトアイコンを確認できるよう表示する。
config.hide_tab_bar_if_only_one_tab = false
-- falseにするとタブバーの透過が効かなくなる
-- config.use_fancy_tab_bar = false

-- タブバーの透過
config.window_frame = {
	inactive_titlebar_bg = "none",
	active_titlebar_bg = "none",
}

-- タブバーを背景色に合わせる
config.window_background_gradient = {
	colors = { "#001829" },
}

-- タブの追加ボタンを非表示
config.show_new_tab_button_in_tab_bar = false
-- nightlyのみ使用可能
-- タブの閉じるボタンを非表示
config.show_close_tab_button_in_tabs = false

-- タブバーの色は tabbar.lua の apply_to_config で設定する。
config.colors = {
	ansi = terminal_colors.ansi,
	brights = terminal_colors.brights,

	cursor_bg = "#1F4B66",
	cursor_fg = "#B7E3E0",
	cursor_border = "#5C9BB3",
}

-- bar.wezterm を設定する前にタブ描画を登録し、番号 + アイコン + 下線のUIにする。
require("tabbar").apply_to_config(config)

----------------------------------------------------
-- Keybindings & CopyMode
----------------------------------------------------
config.disable_default_key_bindings = true
config.leader = { key = "q", mods = "CTRL", timeout_milliseconds = 2000 }

local keys = require("keybinds").keys or {}
local key_tables = require("keybinds").key_tables or {}

table.insert(keys, {
	key = "X",
	mods = "CTRL|SHIFT",
	action = act.ActivateCopyMode,
})
table.insert(keys, transparency.key)

-- CopyMode
key_tables.copy_mode = {
	{ key = "Escape", mods = "NONE", action = act.CopyMode("Close") },
	{ key = "q", mods = "NONE", action = act.CopyMode("Close") },
	{ key = "c", mods = "CTRL", action = act.CopyMode("Close") },

	{ key = "h", mods = "NONE", action = act.CopyMode("MoveLeft") },
	{ key = "j", mods = "NONE", action = act.CopyMode("MoveDown") },
	{ key = "k", mods = "NONE", action = act.CopyMode("MoveUp") },
	{ key = "l", mods = "NONE", action = act.CopyMode("MoveRight") },
	{ key = "w", mods = "NONE", action = act.CopyMode("MoveForwardWord") },
	{ key = "b", mods = "NONE", action = act.CopyMode("MoveBackwardWord") },
	{ key = "e", mods = "NONE", action = act.CopyMode("MoveForwardWordEnd") },
	{ key = "0", mods = "NONE", action = act.CopyMode("MoveToStartOfLine") },
	{ key = "$", mods = "NONE", action = act.CopyMode("MoveToEndOfLineContent") },
	{ key = "^", mods = "NONE", action = act.CopyMode("MoveToStartOfLineContent") },
	{ key = "g", mods = "NONE", action = act.CopyMode("MoveToScrollbackTop") },
	{ key = "G", mods = "SHIFT", action = act.CopyMode("MoveToScrollbackBottom") },
	{ key = "d", mods = "CTRL", action = act.CopyMode({ MoveByPage = 0.5 }) },
	{ key = "u", mods = "CTRL", action = act.CopyMode({ MoveByPage = -0.5 }) },
	{ key = "b", mods = "CTRL", action = act.CopyMode("PageUp") },
	{ key = "f", mods = "CTRL", action = act.CopyMode("PageDown") },
	-- 表示中の画面の上・下・中央へ
	{ key = "H", mods = "NONE", action = act.CopyMode("MoveToViewportTop") },
	{ key = "L", mods = "NONE", action = act.CopyMode("MoveToViewportBottom") },
	{ key = "M", mods = "NONE", action = act.CopyMode("MoveToViewportMiddle") },
	-- 行内の文字へジャンプ(f/t は前方、F/T は後方、; で繰り返し)
	{ key = "f", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = false } }) },
	{ key = "t", mods = "NONE", action = act.CopyMode({ JumpForward = { prev_char = true } }) },
	{ key = "F", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = false } }) },
	{ key = "T", mods = "NONE", action = act.CopyMode({ JumpBackward = { prev_char = true } }) },
	{ key = ";", mods = "NONE", action = act.CopyMode("JumpAgain") },
	-- 選択範囲の反対の端へ
	{ key = "o", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEnd") },
	{ key = "O", mods = "NONE", action = act.CopyMode("MoveToSelectionOtherEndHoriz") },
	{ key = "v", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Cell" }) },
	{ key = "V", mods = "NONE", action = act.CopyMode({ SetSelectionMode = "Line" }) },
	{ key = "v", mods = "CTRL", action = act.CopyMode({ SetSelectionMode = "Block" }) },

	{
		key = "y",
		mods = "NONE",
		action = act.Multiple({
			{ CopyTo = "ClipboardAndPrimarySelection" },
			{ CopyMode = "Close" },
		}),
	},
	{ key = "Enter", mods = "NONE", action = act.CopyMode("ClearSelectionMode") },
}

config.keys = keys
config.key_tables = key_tables

return config
