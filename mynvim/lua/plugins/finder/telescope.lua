local plugin = {}

plugin.core = {
	"nvim-telescope/telescope.nvim",
	--    tag = "0.1.0",
	-- event = { "VimEnter" },
	dependencies = {
		{ "nvim-lua/popup.nvim" },
		{ "nvim-lua/plenary.nvim" },
		{ "tami5/sqlite.lua" },
		{ "tami5/sql.nvim" },
		{ "nvim-telescope/telescope-frecency.nvim" },
		{ "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
		{ "nvim-telescope/telescope-file-browser.nvim" },
		--        {"ahmedkhalf/project.nvim"}
	},

	config = function() -- Specifies code to run after this plugin is loaded
		local actions = require("telescope.actions")
		--[[
        require 'telescope'.load_extension('project')
        --]]
		local action_state = require("telescope.actions.state")

		local custom_actions = {}

		function custom_actions.fzf_multi_select(prompt_bufnr)
			local picker = action_state.get_current_picker(prompt_bufnr)
			local num_selections = table.getn(picker:get_multi_selection())

			if num_selections > 1 then
				-- actions.file_edit throws - context of picker seems to change
				-- actions.file_edit(prompt_bufnr)
				actions.send_selected_to_qflist(prompt_bufnr)
				actions.open_qflist()
			else
				actions.file_edit(prompt_bufnr)
			end
		end

		require("telescope").setup({
			defaults = {
				vimgrep_arguments = {
					"rg",
					"--color=never",
					"--no-heading",
					"--with-filename",
					"--line-number",
					"--column",
					"--smart-case",
				},
				prompt_tag = " ",
				selection_caret = "➤ ",
				entry_tag = " ",
				-- initial_mode = "insert",
				selection_strategy = "reset",
				sorting_strategy = "descending",
				layout_strategy = "horizontal",
				history = {
					path = "~/.local/share/nvim/telescope_history.sqlite3",
				},
				layout_config = {
					horizontal = { mirror = false },
					vertical = { mirror = false },
				},
				file_sorter = require("telescope.sorters").get_fuzzy_file,
				file_ignore_patterns = {},
				generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
				winblend = 0,
				border = {},
				borderchars = {
					"─",
					"│",
					"─",
					"│",
					"╭",
					"╮",
					"╯",
					"╰",
				},
				color_devicons = true,
				use_less = true,
				path_display = {},
				set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
				file_previewer = require("telescope.previewers").vim_buffer_cat.new,
				grep_previewer = require("telescope.previewers").vim_buffer_vimgrep.new,
				qflist_previewer = require("telescope.previewers").vim_buffer_qflist.new,

				-- Developer configurations: Not meant for general override
				buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
				mappings = {
					i = {
						["<esc>"] = actions.close,
						["<C-o>"] = custom_actions.fzf_multi_select,
						["<C-j>"] = actions.cycle_history_next,
						["<C-k>"] = actions.cycle_history_prev,
					},
					n = {
						["<esc>"] = actions.close,
						["<C-o>"] = custom_actions.fzf_multi_select,
					},
				},
			},
			extensions = {
				frecency = {
					show_scores = false,
					show_unindexed = true,
					ignore_patterns = { "*.git/*" },
					workspaces = {},
				},
				--[[
                project = {
                    base_dirs = {
                        '~/.mynvim',
                        '~/org',
                        '~/.dotfiles',
                        '~/workspace',
                    },
                    hidden_files = true -- default: false
                },
                --]]
				-- TODO: switch fuzzy and exact, currently use the telescope-fzf-native
				-- https://github.com/nvim-telescope/telescope.nvim/issues/930
				fzf = {
					fuzzy = true, -- false will only do exact matching
					override_generic_sorter = true, -- override the generic sorter
					override_file_sorter = true, -- override the file sorter
					case_mode = "smart_case", -- or "ignore_case" or "respect_case"
					-- the default case_mode is "smart_case"
				},
			},
		})
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("frecency")

		require("project_nvim").setup({
			manual_mode = true,
			detection_methods = { "lsp", "pattern" },
			patterns = {
				".git",
				"_darcs",
				".hg",
				".bzr",
				".svn",
				"Makefile",
				"package.json",
			},
		})
		require("telescope").load_extension("projects")
		-- require'telescope'.extensions.projects.projects{}
	end,
}

plugin.mapping = {
	keymaps = {
		{
			tag = { "<leader>t", "Telescope", true },
			keymaps = {
				{
					"n",
					"o",
					function()
						require("telescope.builtin").find_files()
					end,
					"Open Folder",
				},
				{
					"n",
					"c",
					function()
						require("telescope.builtin").commands()
					end,
					"Search Commands",
				},
				{
					"n",
					"h",
					function()
						require("telescope.builtin").oldfiles()
					end,
					"Open History",
				},
				{
					"n",
					"r",
					function()
						require("telescope.builtin").resume()
					end,
					"Resume Last",
				},
				{
					"n",
					"b",
					function()
						require("telescope.builtin").buffers()
					end,
					"Buffers",
				},
				{
					"n",
					"q",
					function()
						require("telescope.builtin").quickfix()
					end,
					"Quickfix",
				},
				{
					"n",
					"Q",
					function()
						require("telescope.builtin").quickfixhistory()
					end,
					"Quickfix History",
				},
				{
					"n",
					"f",
					function()
						require("telescope.builtin").current_buffer_fuzzy_find()
					end,
					"Find Current Buffer",
				},
				{
					"n",
					"w",
					function()
						require("telescope.builtin").current_buffer_fuzzy_find({ search = vim.fn.expand("<cword>") })
					end,
					"Find Cword Buffer",
				},
				{
					"n",
					"s",
					function()
						require("telescope.builtin").grep_string()
					end,
					"Search Workspace",
				},
				{
					"n",
					"S",
					function()
						require("telescope.builtin").live_grep()
					end,
					"Live Search Workspace",
				},
				{
					"n",
					"W",
					function()
						require("telescope.builtin").live_grep({ search = vim.fn.expand("cword") })
					end,
					"Live Search Cword Workspace",
				},
				{
					"n",
					"m",
					function()
						require("telescope.builtin").marks()
					end,
					"Marks",
				},
				{
					"n",
					"t",
					function()
						require("telescope.builtin").current_buffer_tags()
					end,
					"Current Buffer Tags",
				},
				{
					"n",
					"H",
					function()
						require("telescope.builtin").help_tags()
					end,
					"List Help Tags",
				},
				{
					"n",
					"O",
					function()
						require("telescope").extensions.file_browser.file_browser({
							prompt_title = "选择目录",
							cwd = vim.fn.getcwd(),
							attach_mappings = function(_, map)
								map("i", "<CR>", function(prompt_bufnr)
									local entry = require("telescope.actions.state").get_selected_entry()
									require("telescope.actions").close(prompt_bufnr)
									require("telescope.builtin").find_files({ cwd = entry[1] })
								end)
								return true
							end,
						})
					end,
					"浏览目录并查找文件",
				},
			},
		},
		{
			tag = { "<leader>tl", "LSP", true },
			keymaps = {
				{
					"n",
					"o",
					function()
						require("telescope.builtin").treesitter()
					end,
					"Treesitter Symbols",
				},
				{
					"n",
					"r",
					function()
						require("telescope.builtin").lsp_references()
					end,
					"References",
				},
				{
					"n",
					"d",
					function()
						require("telescope.builtin").lsp_defineitions()
					end,
					"Defineitions",
				},
				{
					"n",
					"t",
					function()
						require("telescope.builtin").lsp_type_definitions()
					end,
					"Typd Defineitions",
				},
				{
					"n",
					"i",
					function()
						require("telescope.builtin").lsp_implementations()
					end,
					"Implementations",
				},
				{
					"n",
					"s",
					function()
						require("telescope.builtin").lsp_document_symbols()
					end,
					"Document Symbols",
				},
				{
					"n",
					"w",
					function()
						require("telescope.builtin").lsp_dynamic_workspace_symbols()
					end,
					"Document Symbols",
				},
				{
					"n",
					"e",
					function()
						require("telescope.builtin").diagnostics()
					end,
					"Diagnostics",
				},
				{
					"n",
					"c",
					function()
						require("telescope.builtin").lsp_incoming_calls()
					end,
					"InComing Call",
				},
				{
					"n",
					"g",
					function()
						require("telescope.builtin").lsp_outgoing_calls()
					end,
					"OutGoing Calls",
				},
			},
		},
	},
}

return plugin
