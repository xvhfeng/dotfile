local plugin = {}

plugin.core = {
	"petertriho/nvim-scrollbar",
	event = "VeryLazy",

	config = function()
		require("scrollbar").setup({
			set_highlights = true,
			providers = {
				diagnostic = true,
				search = true,
			},
			marks = {
				Search = {
					text = { "-", "=" },
					priority = 0,
					highlight = { fg = "#ff9e64" },
				},
				Error = {
					text = { "-", "=" },
					priority = 1,
					highlight = { fg = "#f7768e" },
				},
				Warn = {
					text = { "-", "=" },
					priority = 2,
					highlight = { fg = "#e0af68" },
				},
				Info = {
					text = { "-", "=" },
					priority = 3,
					highlight = { fg = "#0db9d7" },
				},
				Hint = {
					text = { "-", "=" },
					priority = 4,
					highlight = { fg = "#1abc9c" },
				},
				Misc = {
					text = { "-", "=" },
					priority = 5,
					highlight = { fg = "#9d7cd8" },
				},
			},
			exclude = {
				buftypes = { terminal = true },
				filetypes = {
					prompt = true,
					TelescopePrompt = true,
					NvimTree = true,
				},
			},
			scrollbar = {
				show = true,
				unit = "screenline",
				max_lines = false,
			},
		})
	end,
}

return plugin
