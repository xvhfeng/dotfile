local plugin = {}

plugin.core = {
	"heftyfunseeker/narrow",
	config = function()
		require("narrow").setup({
			-- options, see Configuration section below
			-- there are no required options atm
			-- engine = 'ripgrep' is default, but 'astgrep' can be specified
		})
	end,
}

return plugin
