local plugin = {}

plugin.core = {
    "williamboman/mason.nvim",
    as = "mason",
    require("mason").setup({
        ui = {
            icons = {
                package_installed = "✓",
                package_pending = "➜",
                package_uninstalled = "✗"
            }
        }
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
