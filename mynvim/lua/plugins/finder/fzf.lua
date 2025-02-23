local M = {}

M.core = {
	"ibhagwan/fzf-lua",
	-- optional for icon support
	dependencies = { "nvim-tree/nvim-web-devicons" },

	--[[  
    --keys = {
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

    --]]
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

M.mapping = {
	keymaps = {
		{
			tag = { "<leader>a", "Fzf", usekey = true },
			keymaps = {
				{
					"n",
					"o",
					function()
						require("fzf-lua").files({})
					end,
					"Open Folder",
				},
				{
					"n",
					"h",
					function()
						require("fzf-lua").oldfiles()
					end,
					"Open history",
				},
				{
					"n",
					"r",
					function()
						require("fzf-lua").resume()
					end,
					"Resume Last",
				},
				{
					"n",
					"b",
					function()
						require("fzf-lua").buffers()
					end,
					"OpenedBuffers",
				},
				{
					"n",
					"q",
					function()
						require("fzf-lua").quickfix()
					end,
					"QuickFix List",
				},
				{
					"n",
					"f",
					function()
						require("fzf-lua").grep()
					end,
					"Grep",
				},
				{
					"n",
					"F",
					function()
						require("fzf-lua").grep_last()
					end,
					"Grep Next",
				},
				{
					"n",
					"S",
					function()
						require("fzf-lua").search_history()
					end,
					"Search History",
				},
				{
					"n",
					"w",
					function()
						require("fzf-lua").grep_cword()
					end,
					"Current Word",
				},
				{
					"n",
					"m",
					function()
						require("fzf-lua").marks()
					end,
					"Marks",
				},
				{
					"n",
					"c",
					function()
						require("fzf-lua").changes()
					end,
					"Changes",
				},
				{
					"n",
					"O",
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
					"Open Folder With Input",
				},
			},
		},
		{
			tag = { "<leader>Fl", "FZF LSP", true },
			keymaps = {
				{
					"n",
					"o",
					function()
						require("fzf-lua").treesitter()
					end,
					"Treesitter Symbols",
				},
				{
					"n",
					"r",
					function()
						require("fzf-lua").lsp_references()
					end,
					"References",
				},
				{
					"n",
					"d",
					function()
						require("fzf-lua").lsp_defineitions()
					end,
					"Defineitions",
				},
				{
					"n",
					"D",
					function()
						require("fzf-lua").lsp_declarations()
					end,
					"Declarations",
				},
				{
					"n",
					"t",
					function()
						require("fzf-lua").lsp_typedefs()
					end,
					"Typd Defineitions",
				},
				{
					"n",
					"i",
					function()
						require("fzf-lua").lsp_implementations()
					end,
					"Implementations",
				},
				{
					"n",
					"s",
					function()
						require("fzf-lua").lsp_document_symbols()
					end,
					"Document Symbols",
				},
				{
					"n",
					"e",
					function()
						require("fzf-lua").diagnostics_document()
					end,
					"Diagnostics Document",
				},
				{
					"n",
					"a",
					function()
						require("fzf-lua").lsp_codes_actions()
					end,
					"Code Actions",
				},
				{
					"n",
					"f",
					function()
						require("fzf-lua").lsp_finder()
					end,
					"LSP Locations",
				},
				{
					"n",
					"c",
					function()
						require("fzf-lua").lsp_incoming_calls()
					end,
					"InComing Call",
				},
				{
					"n",
					"g",
					function()
						require("fzf-lua").lsp_outgoing_calls()
					end,
					"OutGoing Calls",
				},
			},
		},
	},
}

return M
