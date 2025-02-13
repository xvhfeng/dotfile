local plugin = {}

plugin.core = {
	"tadaa/vimade",
	desc = "一款高亮显示选中window的插件,比较稳定",
	config = function()
		require("vimade").setup({
			recipe = { "default", { animate = false } },
			ncmode = "windows",
			fadelevel = 0.4,
			tint = {},
			-- see the lazy.nvim config above or `Lua defaults` for full breakdown
		})
	end,
}

return plugin
