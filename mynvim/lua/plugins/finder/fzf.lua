local M = {}

M.core = {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },

	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files({})
			end,
			desc = "Find Files",
		},
		{
			"<leader>fF",
			function()
				local win = require("dressing.input")
				vim.ui.win = win
				vim.ui.input({ prompt = "Enter search query: ", relative = "win" }, function(input)
					if input and input ~= "" then
						require("fzf-lua").files({ cwd = input })
						-- fzf_lua.live_grep({ search = input })
					end
				end)
			end,
			desc = "Open Folder With Input",
		},
		{
			"<leader>fr",
			function()
				require("fzf-lua").resume()
			end,
			desc = "Fzf:Resume",
			"<leader>fg",
			function()
				require("fzf-lua").live_grep({})
			end,
			desc = "Live grep file content",
		},
		{
			"<leader>ob",
			function()
				require("fzf-lua").buffers({})
			end,
			desc = "Search opened buffers",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").manpages({})
			end,
			desc = "Search help manual page",
		},
		{
			"<leader>xd",
			function()
				require("fzf-lua").diagnostics_workspace({})
			end,
			desc = "Workspae Diagnostics",
		},
		{
			"<leader>xx",
			function()
				require("fzf-lua").diagnostics_document({})
			end,
			desc = "Document Diagnostics",
		},
	},

	config = function()
		-- calling `setup` is optional for customization
		require("fzf-lua").setup({
			winopts = {
				-- row = 1.0,
				-- col = 0.0,
				-- height = 0.5,
				-- width = 1.0,
				height = 0.9, -- window height
				width = 0.9, -- window width
				row = 0.45, -- window row position (0=top, 1=bottom)
				backdrop = 100,
				title = "Searching...",
				title_pos = "center", -- 'left', 'center' or 'right',
			},
			fzf_opts = {
				["--ansi"] = true,
				["--info"] = "inline-right", -- fzf < v0.42 = "inline"
				["--height"] = "100%",
				["--layout"] = "reverse-list",
				["--border"] = "none",
				["--highlight-line"] = true, -- fzf >= v0.53
			},
		})
	end,
}

return M
