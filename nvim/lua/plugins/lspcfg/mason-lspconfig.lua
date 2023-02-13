local plugin = {}

plugin.core = {
    "williamboman/mason-lspconfig.nvim",

        require("mason-lspconfig").setup({
            ensure_installed = {
                "sumneko_lua",
                "clangd",
                "gopls",
                "golangci_lint_ls",
                "rust_analyzer",
                "awk_ls",
                "clangd",
                "jdtls",
                "jsonls",
                "bashls",
                "tsserver",
                "sqlls",
                "pyright",
            },
        })
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
