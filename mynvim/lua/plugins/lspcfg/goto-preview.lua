local m = {}

m.core = {
	"rmagatti/goto-preview",
	event = "BufEnter",
	config = true,
	dependencies = { "rmagatti/logger.nvim" },
}

m.mapping = {
	keymaps = {
		{
			tag = { "<leader>lp", "Preview", true },
			keymaps = {
				{
					"n",
					"d",
					function()
						require("goto-preview").goto_preview_definition()
					end,
					"Preview Definition",
				},
				{
					"n",
					"t",
					function()
						require("goto-preview").goto_preview_type_definition()
					end,
					"Preview Type Definition",
				},
				{
					"n",
					"i",
					function()
						require("goto-preview").goto_preview_implementation()
					end,
					"Preview Implementation",
				},
				{
					"n",
					"c",
					function()
						require("goto-preview").goto_preview_declaration()
					end,
					"Preview Declaration",
				},
				{
					"n",
					"x",
					function()
						require("goto-preview").close_all_win()
					end,
					"Close Preview View",
				},
				{
					"n",
					"X",
					function()
						require("goto-preview").close_all_win({ skip_curr_window = true })
					end,
					"Close Other View",
				},
				{
					"n",
					"r",
					function()
						require("goto-preview").goto_preview_references()
					end,
					"Preview References",
				},
			},
		},
	},
}
return m
