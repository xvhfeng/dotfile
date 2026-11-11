local plugin = {}

local function keymap()
	vim.keymap.set("n", "ge", vim.diagnostic.open_float)
	vim.keymap.set("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end)
	vim.keymap.set("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end)
	vim.keymap.set("n", "gq", vim.diagnostic.setloclist)

	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
		callback = function(ev)
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
			local opts = { buffer = ev.buf }
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
			vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
			vim.keymap.set("n", "gk", vim.lsp.buf.hover, opts)
			vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
			vim.keymap.set("n", "gK", vim.lsp.buf.signature_help, opts)
			vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
			vim.keymap.set("n", "<leader>wd", vim.lsp.buf.remove_workspace_folder, opts)
			vim.keymap.set("n", "<leader>wL", function()
				print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
			end, opts)
			vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
			vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
			vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
			vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
			vim.keymap.set("n", "<leader>fF", function()
				vim.lsp.buf.format({ async = true })
			end, opts)
		end,
	})
end

plugin.core = {
	"mason-org/mason-lspconfig.nvim",
	dependencies = {
		{ "mason-org/mason.nvim" },
		"neovim/nvim-lspconfig",
		"hrsh7th/cmp-nvim-lsp",
	},
	config = function()
		require("mason").setup()

		-- These capabilities apply to every server, including ones installed later by Mason.
		vim.lsp.config("*", {
			capabilities = require("cmp_nvim_lsp").default_capabilities(),
		})
		vim.lsp.config("lua_ls", {
			settings = {
				Lua = {
					runtime = { version = "LuaJIT" },
					diagnostics = { globals = { "vim" } },
				},
			},
		})
		vim.lsp.config("pylsp", {
			settings = { pylsp = { plugins = { pyflakes = { enabled = true } } } },
		})

		require("mason-lspconfig").setup({
			ensure_installed = {
				"lua_ls", "bashls", "jdtls", "clangd", "cmake", "eslint",
				"ts_ls", "marksman", "sqlls", "yamlls", "vimls",
				"gopls", "pylsp",
			},
			automatic_enable = true,
		})
		keymap()
	end,
}

return plugin
