local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

sbar.exec(
	"killall memory_load >/dev/null; $CONFIG_DIR/helpers/event_providers/memory_load/bin/memory_load memory_update 2.0"
)

local memory = sbar.add("item", "widgets.memory", {
	position = "right",
	icon = {
		string = icons.memory,
		color = colors.tn_blue,
		font = { size = 18 },
	},
	label = {
		string = "??%",
		color = colors.tn_blue,
		font = { family = settings.font.numbers },
		align = "right",
	},
	padding_right = 8,
	padding_left = 8,
})

local bracket = sbar.add("bracket", "widgets.memory.bracket", { memory.name }, {
	background = {
		color = colors.tn_black3,
		border_color = colors.tn_blue,
		border_width = 1,
	},
})

sbar.add("item", "widgets.memory.padding", {
	position = "right",
	width = settings.group_paddings,
})

memory:subscribe("memory_update", function(env)
	local pct = tonumber(env.used_percentage) or 0
	local color = colors.tn_blue
	if pct > 60 then color = colors.tn_orange end
	if pct > 80 then color = colors.tn_red end
	memory:set({
		label = { string = string.format("%d%%", pct), color = color },
		icon = { color = color },
	})
	bracket:set({ background = { border_color = color } })
end)

memory:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)
