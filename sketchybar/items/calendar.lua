local colors = require("colors")
local settings = require("settings")


local cal_clock = sbar.add("item", {
	icon = { drawing = "off" },
	label = {
		color = colors.tn_blue,
		padding_right = 0,
		align = "right",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 0,
	padding_right = 8,
})

local cal_day = sbar.add("item", {
	icon = { drawing = "off" },
	label = {
		color = colors.tn_blue,
		align = "center",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 0,
	padding_right = 0,
})

local cal_month = sbar.add("item", {
	icon = { drawing = "off" },
	label = {
		color = colors.tn_skyblue,
		align = "center",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 0,
	padding_right = 0,
})

local cal_day_of_week = sbar.add("item", {
	icon = { drawing = "off" },
	label = {
		color = colors.tn_white3,
		align = "center",
		font = { family = settings.font.numbers },
	},
	position = "right",
	update_freq = 1,
	padding_left = 8,
	padding_right = 0,
})

sbar.add("bracket", { cal_day_of_week.name, cal_month.name, cal_day.name, cal_clock.name }, {
	background = {
		color = colors.tn_black3,
		height = 28,
		border_color = colors.tn_blue,
		border_width = 1,
	},
})

sbar.add("item", { position = "right", width = settings.group_paddings })

local function update_cal(env)
	cal_clock:set({ label = os.date("%H:%M") })
	cal_month:set({ label = os.date("%b") })
	cal_day_of_week:set({ label = os.date("%a") })
	cal_day:set({ label = os.date("%d") })
end

sbar.add("item", { position = "right", width = 6 })

-- subscribe をまとめて1回に
cal_clock:subscribe({ "forced", "routine", "system_woke" }, update_cal)
