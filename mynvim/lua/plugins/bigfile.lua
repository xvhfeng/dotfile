local m = {}

m.core = {
	"LunarVim/bigfile.nvim",
	desc = "一个解决打开大文件时，vim卡顿的插件。",

	config = function()
		require("bigfile").setup({})
	end,
}

return m
