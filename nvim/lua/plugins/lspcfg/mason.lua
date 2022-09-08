local plugin = {}

plugin.core = {
    "williamboman/mason.nvim",
    disable = false,
    opt=false,

    as = "mason",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require("mason").setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗"
                }
            }
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