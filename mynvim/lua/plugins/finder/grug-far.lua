local plugin = {}

plugin.core = {
	"MagicDuck/grug-far.nvim",
	config = function()
		require("grug-far").setup({
			-- options, see Configuration section below
			-- there are no required options atm
			-- engine = 'ripgrep' is default, but 'astgrep' can be specified
		})
	end,
}

plugin.mapping = {
	keymaps = {
		{
			tag = { "<leader>f", "Find/Replace", true },
			keymaps = {
				{
					"n",
					"g",
					function()
						require("grug-far").open(opts)
					end,
					"God Find&Replace",
				},
			},
		},
	},
}

return plugin
