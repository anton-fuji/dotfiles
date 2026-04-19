local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

sbar.exec(
	"killall cpu_load >/dev/null; $CONFIG_DIR/helpers/event_providers/cpu_load/bin/cpu_load cpu_update 2.0"
)

local cpu_graph = sbar.add("graph", "widgets.cpu.graph", 60, {
	position = "right",
	height = 27,
	graph = {
		color = colors.tn_blue,
		line_width = 1.0,
	},
	y_offset = 4,
	padding_right = 0,
	padding_left = -10,
})

local cpu = sbar.add("item", "widgets.cpu", {
	position = "right",
	background = {
		height = 22,
		color = { alpha = 0 },
		border_color = { alpha = 0 },
		drawing = true,
	},
	icon = {
		string = icons.cpu,
		color = colors.tn_blue,
	},
	label = {
		string = "??%",
		color = colors.tn_blue,
		font = { family = settings.font.numbers },
		align = "right",
	},
	padding_right = 0,
	padding_left = 5,
})

local bracket = sbar.add("bracket", "widgets.cpu.bracket", { cpu_graph.name, cpu.name }, {
	background = {
		color = colors.tn_black3,
		border_color = colors.tn_blue,
		border_width = 1,
	},
})

cpu_graph:subscribe("cpu_update", function(env)
	local load = tonumber(env.total_load)
	cpu_graph:push({ load / 150.0 })
	local color = colors.tn_blue
	local fill_color = colors.with_alpha(color, 0.3)
	if load > 30 then
		if load < 60 then
			color = colors.tn_yellow
		elseif load < 80 then
			color = colors.tn_orange
		else
			color = colors.tn_red
		end
		fill_color = colors.with_alpha(color, 0.3)
	end
	cpu_graph:set({ graph = { color = color, fill_color = fill_color } })
	cpu:set({
		label = { string = env.total_load .. "%", color = color },
		icon = { color = color },
	})
	bracket:set({ background = { border_color = color } })
end)

cpu:subscribe("mouse.clicked", function(env)
	sbar.exec("open -a 'Activity Monitor'")
end)

sbar.add("item", "widgets.cpu.padding", {
	position = "right",
	width = settings.group_paddings,
})
