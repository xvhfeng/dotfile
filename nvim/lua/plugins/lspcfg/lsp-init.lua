local plugin = {}

function loading()
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
end

plugin.core = {
    "williamboman/mason.nvim", -- 下载对应语言所需要的LSP服务器
    "williamboman/mason-lspconfig.nvim", -- mason与nvim-lspconfig的连接器,自动安装lspserv
    "neovim/nvim-lspconfig", -- 配置LSP服务器
    run = ":MasonUpdate",
    loading()

}

plugin.mapping = function()
    --[===[
:Mason - opens a graphical status window
:MasonInstall <package> ... - installs/reinstalls the provided packages
:MasonUninstall <package> ... - uninstalls the provided packages
:MasonUninstallAll - uninstalls all packages
:MasonLog - opens the mason.nvim log file in a new tab window
--]===]
end

return plugin
