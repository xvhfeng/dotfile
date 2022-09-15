local plugin = {}

plugin.core = {
    "williamboman/mason-lspconfig.nvim",
    as = "mason-lspconfig",

    config = function() -- Specifies code to run after this plugin is loaded
        require("mason-lspconfig").setup({
            ensure_installed = {
                "bashls",
                "clangd",
                "cmake",
                "gopls",
                "jsonls",
                "jdtls",
                "tsserver",
                "ltex",
                "sumneko_lua",
                "marksman",
                "pyright",
                "sqlls",
                "rust_analyzer" }
        })
    end,
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
