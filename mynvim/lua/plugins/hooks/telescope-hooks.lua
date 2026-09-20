local plugin = {}

plugin.core = { only_hooks = true }

plugin.hooks_init = function()
	local telescope = require("telescope")

	telescope.setup({
		defaults = {
			mappings = {
				i = {
					["<c-t>"] = function(prompt_bufnr)
						require("trouble.sources.telescope").open(prompt_bufnr)
					end,
				},
				n = {
					["<c-t>"] = function(prompt_bufnr)
						require("trouble.sources.telescope").open(prompt_bufnr)
					end,
				},
			},
		},
	})
end

return plugin
