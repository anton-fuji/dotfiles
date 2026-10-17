local wezterm = require("wezterm")
local nf = wezterm.nerdfonts

local M = {}

local palette = {
  base = "#001829",
  text = "#8FBFBB",
  muted = "#4F7397",
  icon = "#84A0C6",
}

local tab_colors = {
  active = { index = "#5C9BB3", icon = palette.icon, title = "#9DB5D6" },
  inactive = { index = palette.muted, icon = palette.muted, title = palette.muted },
  hover = { index = "#5C9BB3", icon = palette.icon, title = palette.icon },
}

local function display_title(tab)
  -- Prefer the explicit title assigned by the project picker. Zellij can
  -- change the active pane title, but that should not hide the project icon.
  local title = tab.tab_title
  if not title or title == "" then
    title = require("bar.tabs").get_title(tab)
  end
  title = title or ""
  local project_path = title:match("^project:(.+)$")
  if project_path then
    return project_path:match("([^/]+)$") or project_path
  end
  return title
end

local function format_tab_title(tab, _, _, config, hover)
  local title = display_title(tab)
  local active = tab.is_active
  local colors = active and tab_colors.active or (hover and tab_colors.hover or tab_colors.inactive)
  local index = tab.tab_index + 1
  -- Use the Material Design glyph, which is covered by WezTerm's bundled
  -- Nerd Font Symbols fallback more broadly than the newer Font Awesome glyph.
  local icon = nf.md_ghost

  -- Use the configured tab width: WezTerm's second formatting pass may pass
  -- the width of the previous result, which can progressively shorten labels.
  local max_width = config.tab_max_width or 48
  local max_title = math.max(1, max_width - 12)
  title = wezterm.truncate_right(title, max_title)

  return {
    { Background = { Color = palette.base } },
    { Foreground = { Color = colors.index } },
    { Attribute = { Intensity = "Bold" } },
    { Text = " " .. index .. " " },
    { Attribute = { Intensity = active and "Bold" or "Normal" } },
    { Attribute = { Underline = active and "Single" or "None" } },
    { Foreground = { Color = colors.icon } },
    { Text = icon .. " " },
    { Foreground = { Color = colors.title } },
    { Text = title },
    { Attribute = { Underline = "None" } },
    { Attribute = { Intensity = "Normal" } },
    { Text = " " },
  }
end

function M.apply_to_config(config)
  -- Register before bar.wezterm: WezTerm uses the first formatter registered.
  wezterm.on("format-tab-title", format_tab_title)

  config.enable_tab_bar = true
  config.tab_max_width = 48
  config.tab_bar_at_bottom = true
  config.use_fancy_tab_bar = false
  config.colors.tab_bar = {
    background = palette.base,
    active_tab = { bg_color = palette.base, fg_color = tab_colors.active.title },
    inactive_tab = { bg_color = palette.base, fg_color = tab_colors.inactive.title },
    inactive_tab_hover = { bg_color = palette.base, fg_color = tab_colors.hover.title },
    new_tab = { bg_color = palette.base, fg_color = palette.text },
    inactive_tab_edge = "none",
  }

  local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
  bar.apply_to_config(config, {
    position = "bottom",
    max_width = 48,
    modules = {
      tabs = {
        active_tab_fg = tab_colors.active.title,
        active_tab_bg = palette.base,
        inactive_tab_fg = tab_colors.inactive.title,
        inactive_tab_bg = palette.base,
        tab_hover_fg = tab_colors.hover.title,
        tab_hover_bg = palette.base,
        new_tab_fg = palette.text,
        new_tab_bg = palette.base,
      },
      -- bar.wezterm's installed revision indexes colors through palette.ansi,
      -- so status-module colors must be ANSI indices rather than hex strings.
      workspace = { enabled = true, icon = nf.md_weather_night, color = 8 },
      leader = { enabled = true, icon = nf.oct_rocket, color = 2 },
      zoom = { enabled = false },
      pane = { enabled = false },
      username = { enabled = false },
      hostname = { enabled = false },
      cwd = { enabled = false, icon = nf.oct_file_directory, color = 3 },
      clock = {
        enabled = true,
        icon = nf.md_calendar_clock,
        format = "%m/%d %H:%M",
        color = 6,
      },
      ssh = { enabled = false },
      spotify = { enabled = false },
    },
  })

  -- Keep the plugin's workspace/tab UI, but render the clock directly so it
  -- remains visible even when the plugin's right-side module is not applied.
  wezterm.on("update-status", function(window)
    window:set_right_status(wezterm.format({
      { Background = { Color = palette.base } },
      { Foreground = { Color = "#A093C7" } },
      { Text = nf.md_calendar_clock .. " " .. wezterm.strftime("%m/%d %H:%M") .. " " },
    }))
  end)
end

return M
