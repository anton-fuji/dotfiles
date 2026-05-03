local wezterm = require("wezterm")

local M = {}

local is_transparent = false

wezterm.on("toggle-transparency", function(window)
  if is_transparent then
    window:set_config_overrides({
      window_background_opacity = 0.55,
      macos_window_background_blur = 20,
    })
  else
    window:set_config_overrides({
      window_background_opacity = 0.10,
      macos_window_background_blur = 0,
    })
  end
  is_transparent = not is_transparent
end)

M.key = {
  key = "S",
  mods = "CMD|SHIFT",
  action = wezterm.action.EmitEvent("toggle-transparency"),
}

return M
