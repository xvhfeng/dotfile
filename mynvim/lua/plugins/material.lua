local plugin = {}

plugin.core = {
    "marko-cerovac/material.nvim",
    config = function()
        vim.g.material_style = "palenight"
        vim.cmd 'colorscheme material'

        plugins = { -- Uncomment the plugins that you use to highlight them
            "dap",
            "hop",
            "indent-blankline",
            "lspsaga",
            "neorg",
            "nvim-cmp",
            "nvim-navic",
            "nvim-tree",
            "nvim-web-devicons",
            "telescope",
            "trouble",
            "which-key",
        }
    end
    -- vim.cmd("hi clear Cursor")
}

return plugin
