local plugin = {}

plugin.hydra_leader = ";"

plugin.core = {
	"nvimtools/hydra.nvim",
	config = function()
		require("hydra").setup({
			color = "red",
			hint = {
				type = "window",
				position = "bottom",
				float_opts = { border = "rounded" },
			},
		})
	end,
}

return plugin
