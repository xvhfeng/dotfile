local plugin = {}

plugin.core = {
    "mfussenegger/nvim-dap",
    disable = false,
    opt=false,

    as = "nvim-dap",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require("mason").setup()
    end,
}

plugin.mapping = function()

end

return plugin