local m = {}

--[[
m.core = {
	"anuvyklack/middleclass",
	"anuvyklack/animation.nvim",
	"anuvyklack/windows.nvim",
	config = function()
		require("windows").setup({})
	end,
}

--]]
m.core = { "szw/vim-maximizer" }

m.mapping = {
	keymaps = {
		{
			mode = "n",
			key = "<leader>wo",
			action = "<cmd>MaximizerToggle<cr>",
			desc = "Toggle Window Maxsize",
		},
	},
}
return m
