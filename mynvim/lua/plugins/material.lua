local plugin = {}

plugin.core = {
    "marko-cerovac/material.nvim",
    config = function()
        vim.g.material_style = "palenight"
        vim.cmd 'colorscheme material'
        vim.cmd("hi clear Cursor")
    end
}

return plugin
