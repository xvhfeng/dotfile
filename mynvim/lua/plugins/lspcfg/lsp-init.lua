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

    local opts = { noremap = true, silent = true }
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

    -- Use an on_attach function to only map the following keys
    -- after the language server attaches to the current buffer
    local on_attach = function(client, bufnr)
        -- Enable completion triggered by <c-x><c-o>
        vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
        vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
        vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    end


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
            on_attach = on_attach
        end,
        ["clangd"] = function()
            lspconfig.clangd.setup {
                cmd = {"clangd", -- "--header-insertion=never",
                    "--query-driver=/opt/homebrew/opt/llvm/bin/clang++" -- "--all-scopes-completion",
                    -- "--completion-style=detailed",
                }
            }
            on_attach = on_attach
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
