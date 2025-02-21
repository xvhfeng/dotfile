local m = {}

m.core = {
	"johmsalas/text-case.nvim",
	desc = "对单词进行大小写的插件",
	dependencies = { "nvim-telescope/telescope.nvim" },
	config = function()
		require("textcase").setup({})
		require("telescope").load_extension("textcase")
	end,
}

m.mapping = {
	keymaps = {
		{
			tag = { "<leader>et", "CaseCurrentWord", true },
			keymaps = {
				{
					"n",
					"u",
					function()
						require("textcase").current_word("to_upper_case")
					end,
					"To Upper",
				},
				{
					"n",
					"l",
					function()
						require("textcase").current_word("to_lower_case")
					end,
					"To Lower",
				},
				{
					"n",
					"s",
					function()
						require("textcase").current_word("to_snake_case")
					end,
					"To Snake",
				},
				{
					"n",
					"d",
					function()
						require("textcase").current_word("to_dash_case")
					end,
					"To Dash",
				},
				{
					"n",
					"n",
					function()
						require("textcase").current_word("to_constant_case")
					end,
					"To Constant",
				},
				{
					"n",
					"d",
					function()
						require("textcase").current_word("to_dot_case")
					end,
					"To Dot",
				},
				{
					"n",
					"m",
					function()
						require("textcase").current_word("to_comma_case")
					end,
					"To Comma",
				},
				{
					"n",
					"a",
					function()
						require("textcase").current_word("to_phrase_case")
					end,
					"To Phrase",
				},
				{
					"n",
					"c",
					function()
						require("textcase").current_word("to_camel_case")
					end,
					"To Camel",
				},
				{
					"n",
					"p",
					function()
						require("textcase").current_word("to_pascal_case")
					end,
					"To Pascal",
				},
				{
					"n",
					"t",
					function()
						require("textcase").current_word("to_title_case")
					end,
					"To Title",
				},
				{
					"n",
					"f",
					function()
						require("textcase").current_word("to_path_case")
					end,
					"To Path",
				},
			},
		},
		{
			tag = { "<leader>el", "CaseLSPWord", true },
			keymaps = {
				{
					"n",
					"u",
					function()
						require("textcase").lsp_rename("to_upper_case")
					end,
					"To Upper",
				},
				{
					"n",
					"l",
					function()
						require("textcase").lsp_rename("to_lower_case")
					end,
					"To Lower",
				},
				{
					"n",
					"s",
					function()
						require("textcase").lsp_rename("to_snake_case")
					end,
					"To Snake",
				},
				{
					"n",
					"d",
					function()
						require("textcase").lsp_rename("to_dash_case")
					end,
					"To Dash",
				},
				{
					"n",
					"n",
					function()
						require("textcase").lsp_rename("to_constant_case")
					end,
					"To Constant",
				},
				{
					"n",
					"d",
					function()
						require("textcase").lsp_rename("to_dot_case")
					end,
					"To Dot",
				},
				{
					"n",
					"m",
					function()
						require("textcase").lsp_rename("to_comma_case")
					end,
					"To Comma",
				},
				{
					"n",
					"a",
					function()
						require("textcase").lsp_rename("to_phrase_case")
					end,
					"To Phrase",
				},
				{
					"n",
					"c",
					function()
						require("textcase").lsp_rename("to_camel_case")
					end,
					"To Camel",
				},
				{
					"n",
					"p",
					function()
						require("textcase").lsp_rename("to_pascal_case")
					end,
					"To Pascal",
				},
				{
					"n",
					"t",
					function()
						require("textcase").lsp_rename("to_title_case")
					end,
					"To Title",
				},
				{
					"n",
					"f",
					function()
						require("textcase").lsp_rename("to_path_case")
					end,
					"To Path",
				},
			},
		},

		{
			tag = { "<leader>ep", "CaseOperatorWord", true },
			keymaps = {
				{
					"n",
					"u",
					function()
						require("textcase").operator("to_upper_case")
					end,
					"To Upper",
				},
				{
					"n",
					"l",
					function()
						require("textcase").operator("to_lower_case")
					end,
					"To Lower",
				},
				{
					"n",
					"s",
					function()
						require("textcase").operator("to_snake_case")
					end,
					"To Snake",
				},
				{
					"n",
					"d",
					function()
						require("textcase").operator("to_dash_case")
					end,
					"To Dash",
				},
				{
					"n",
					"n",
					function()
						require("textcase").operator("to_constant_case")
					end,
					"To Constant",
				},
				{
					"n",
					"d",
					function()
						require("textcase").operator("to_dot_case")
					end,
					"To Dot",
				},
				{
					"n",
					"m",
					function()
						require("textcase").operator("to_comma_case")
					end,
					"To Comma",
				},
				{
					"n",
					"a",
					function()
						require("textcase").operator("to_phrase_case")
					end,
					"To Phrase",
				},
				{
					"n",
					"c",
					function()
						require("textcase").operator("to_camel_case")
					end,
					"Tp Camel",
				},
				{
					"n",
					"p",
					function()
						require("textcase").operator("to_pascal_case")
					end,
					"To Pascal",
				},
				{
					"n",
					"t",
					function()
						require("textcase").operator("to_title_case")
					end,
					"To Title",
				},
				{
					"n",
					"f",
					function()
						require("textcase").operator("to_path_case")
					end,
					"To Path",
				},
			},
		},
	},
}

return m
