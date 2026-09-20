local plugin = {}

local keymap = function()
	-- Global mappings.
	-- See `:help vim.diagnostic.*` for documentation on any of the below functions
	vim.keymap.set("n", "ge", vim.diagnostic.open_float)
	vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
	vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
	vim.keymap.set("n", "gq", vim.diagnostic.setloclist)

	-- Use LspAttach autocommand to only map the following keys
	-- after the language server attaches to the current buffer
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("UserLspConfig", {}),
		callback = function(ev)
			vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
			-- Enable completion triggered by <c-x><c-o>

			-- Buffer local mappings.
			-- See `:help vim.lsp.*` for documentation on any of the below functions
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
	-- 多多少少，mason.nvim的github上的配置在我机器上有点问题
	-- 所以取消mason与lspconfig的lazy load，直接启动就加载
	"neovim/nvim-lspconfig",
	dependencies = {
		{
			"tamago324/nlsp-settings.nvim",
		},
		{
			"williamboman/mason.nvim",
			lazy = false,
		},
		{
			"williamboman/mason-lspconfig.nvim",
			lazy = false,
		},
	},
	config = function()
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local lspconfig = require("lspconfig")
		local nlspsettings = require("nlspsettings")
		mason.setup({})
		mason_lspconfig.setup({
			ensure_installed = {
				"lua_ls",
				"bashls",
				"jdtls",
				"clangd",
				"cmake",
				"eslint",
				--"jsonls",
				--"tsserver",
				"ts_ls",
				"marksman",
				"sqlls",
				"yamlls",
				"vimls",
				"gopls",
				"pylsp",
			},
			automatic_installation = true,
		})

		-- local nlspsettings = require("nlspsettings")

		nlspsettings.setup({
			config_home = vim.g.CONFIG .. "/nlsp-settings",
			local_settings_dir = ".nlsp-settings",
			local_settings_root_markers_fallback = { ".git", ".root", ".project", ".github" },
			append_default_schemas = true,
			loader = "json",
		})

		local global_capabilities = vim.lsp.protocol.make_client_capabilities()
		global_capabilities.textDocument.completion.completionItem.snippetSupport = true

		lspconfig.util.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
			capabilities = global_capabilities,
		})

		--		mason.setup()
		--		mason_lspconfig.setup()
		--	version 2.0 使用setup
		--	version < 2.0 使用setup_handlers
		mason_lspconfig.setup({
			handlers = {
				function(server_name)
					lspconfig[server_name].setup({})
				end,
			},
		})
		--[[
		-- 下述的lsp.lsconfig-xxx，都是lsp文件夹下的各种文件
		local config_tb = {
			require("plugins/lspcfg/setup/bashls"),
			require("plugins/lspcfg/setup/clangd"),
			require("plugins/lspcfg/setup/cmake"),
			require("plugins/lspcfg/setup/eslint"),
			require("plugins/lspcfg/setup/gopls"),
			require("plugins/lspcfg/setup/jdtls"),
			require("plugins/lspcfg/setup/lua_ls"),
			require("plugins/lspcfg/setup/marksman"),
			require("plugins/lspcfg/setup/tsserver"),
			require("plugins/lspcfg/setup/vimls"),
			require("plugins/lspcfg/setup/yamlls"),
		}
		--
		local lspconfig = require("lspconfig")
		for _, cfg in ipairs(config_tb) do
			-- 取到配置
			local setup_config = cfg.setup_config
			-- 为每一个语言服务进行setup
			lspconfig[cfg.name].setup(setup_config)
		end

		require("plugins/lspcfg/setup/sqlls")
		require("plugins/lspcfg/setup/pyright")
        --]]
		keymap()
	end,
}

return plugin
