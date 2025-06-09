local M = {}

M.core = {
	"linux-cultist/venv-selector.nvim",
	dependencies = { "neovim/nvim-lspconfig", "nvim-telescope/telescope.nvim", "mfussenegger/nvim-dap-python" },
	opts = {
		-- Your options go here
		-- name = "venv",
		-- auto_refresh = false
	},
	event = "VeryLazy", -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
}

M.mapping = {
	keymaps = {
		{
			tag = { "<leader>v", "VEnv", true },
			keymaps = {
				{
					mode = "n",
					key = "s",
					action = "<cmd>VenvSelect<cr>",
					desc = "Select Python VEnv",
				},
				{
					mode = "n",
					key = "c",
					action = "<cmd>VenvSelectCached<cr>",
					desc = "Select Python VEnv From Cached",
				},
			},
		},
	},
}
return M
