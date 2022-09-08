local plugin = {}

plugin.core = {
    "mfussenegger/nvim-dap",
    as = "nvim-dap",

    config = function() -- Specifies code to run after this plugin is loaded
        require("mason").setup()
    end,
}

return plugin
