local plugin = {}

function loading()
    --[[ 
    require("mason").setup()
    require("mason-lspconfig").setup{
        ensure_installed = {
            "awk_ls",
            "bashls",
            "clangd",
            "gopls",
            "jdtls",
            "jsonls",
            "lua_ls",
            "pyright",
            "rust_analyzer",
            "sqlls",
            "tsserver",
        },
        automatic_installation = true,
    }
    local lspcfg = require('lspconfig')
    lspcfg.awk_ls.setup{}
    lspcfg.bashls.setup{}
     lspcfg.clangd.setup{}
    lspcfg.gopls.setup{}
    lspcfg.jdtls.setup{}
    lspcfg.jsonls.setup{}
    lspcfg.lua_ls.setup{}
    lspcfg.pyright.setup{}
    lspcfg.rust_analyzer.setup{}
    lspcfg.sqlls.setup{}
    lspcfg.tsserver.setup{}
    --]]

    -- 

    require("mason").setup()
    require("mason-lspconfig").setup({
        ensure_installed = {"lua_ls", "bashls", "gopls", "jdtls", "clangd", "cmake", "pyright"},
        automatic_installation = true
    })

    local lspconfig = require('lspconfig')

    require("mason-lspconfig").setup_handlers({
        function(server_name)
            require("lspconfig")[server_name].setup {}
        end,
        -- Next, you can provide targeted overrides for specific servers.
        ["lua_ls"] = function()
            lspconfig.lua_ls.setup {
                settings = {
                    Lua = {
                        diagnostics = {
                            globals = {"vim"}
                        }
                    }
                }
            }
        end,
        ["clangd"] = function()
            lspconfig.clangd.setup {
                cmd = {"clangd", -- "--header-insertion=never",
                "--query-driver=/opt/homebrew/opt/llvm/bin/clang++" -- "--all-scopes-completion",
                -- "--completion-style=detailed",
                }
            }
        end
    })

    --  require('mason.api.command').MasonUpdate()
end

plugin.core = {
    "neovim/nvim-lspconfig",
    dependencies = {{
        "folke/neoconf.nvim",
        cmd = "Neoconf",
        config = true
    }, {
        "folke/neodev.nvim",
        opts = {}
    }, {"williamboman/mason.nvim" ,
build = "MasonUpdate"}, {"williamboman/mason-lspconfig.nvim"}, {"hrsh7th/cmp-nvim-lsp"}},

    init = function()
        loading()
    end
}

--[===[

:Mason - opens a graphical status window
:MasonInstall <package> ... - installs/reinstalls the provided packages
:MasonUninstall <package> ... - uninstalls the provided packages
:MasonUninstallAll - uninstalls all packages
:MasonLog - opens the mason.nvim log file in a new tab window
--]===]

return plugin
