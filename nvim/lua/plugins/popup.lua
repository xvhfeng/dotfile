local plugin = {}

plugin.core = {
    "nvim-lua/popup.nvim",
    disable = false,
    opt=false,


    requires = {
        {"nvim-lua/plenary.nvim"},
    },


    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        -- vim.cmd [[highlight PmenuSel ctermbg=lightblue guibg=lightblue]]
        -- vim.cmd [[highlight PmenuSel ctermbg=lightcyan guibg=lightcyan]]
    end,
}

plugin.mapping = function()
end

return plugin
