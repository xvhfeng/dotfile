local plugin = {}

plugin.core = {
	"ariel-frischer/bmessages.nvim",
	name = "bmessages",
	config = function()
		require("bmessages").setup({
			timer_interval = 500,
			split_type = "split",
			split_direction = "botright",
			split_size_split = 12,
			autoscroll = true,
			use_timer = true,
			keep_focus = true,
		})
	end,
}

return plugin
