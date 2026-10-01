return {
	"saghen/blink.cmp",
	version = "1.*",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		{
			"L3MON4D3/LuaSnip",
			version = "v2.*",
			build = "make install_jsregexp",
			dependencies = { "rafamadriz/friendly-snippets" },
			config = function()
				require("extensions.snippets")
			end,
		},
	},
	opts = {
		keymap = {
			preset = "default",
			["<CR>"] = { "select_and_accept", "fallback" },
			["<Tab>"] = {
				"select_next",
				function()
					local luasnip = require("luasnip")
					if luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
						return true
					end
				end,
				"fallback",
			},
			["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
		},
		snippets = { preset = "luasnip" },
		sources = { default = { "lsp", "path", "snippets", "buffer" } },
		completion = {
			list = { selection = { preselect = false, auto_insert = false } },
			-- 括弧入力は既存の nvim-autopairs に任せる。
			accept = { auto_brackets = { enabled = false } },
			menu = {
				border = "rounded",
				draw = {
					columns = {
						{ "kind_icon" },
						{ "label", "label_description", gap = 1 },
						{ "kind" },
						{ "source_name" },
					},
				},
			},
			documentation = { auto_show = true, auto_show_delay_ms = 250, window = { border = "rounded" } },
		},
		cmdline = {
			enabled = true,
			keymap = { preset = "cmdline" },
		},
		fuzzy = { implementation = "prefer_rust" },
	},
}
