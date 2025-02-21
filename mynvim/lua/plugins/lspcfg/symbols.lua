local m = {}

m.core = {
	"oskarrrrrrr/symbols.nvim",
	config = function()
		local r = require("symbols.recipes")
		require("symbols").setup(r.DefaultFilters, r.AsciiSymbols, {
			-- custom settings here
			-- e.g. hide_cursor = false
		})
		vim.keymap.set("n", ",s", "<cmd> Symbols<CR>")
		vim.keymap.set("n", ",S", "<cmd> SymbolsClose<CR>")
	end,
}

m.mapping = {
	keymaps = {
		{
			tag = { "<leader>ly", "Symbols", true },
			keymaps = {
				{ "n", "s", "<cmd> Symbols<CR>", "Symbols" },
				{ "n", "S", "<cmd> SymbolsClose<CR>", "SymbolsClose" },
			},
		},
	},
}

return m
