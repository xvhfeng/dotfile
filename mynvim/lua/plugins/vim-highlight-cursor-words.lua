
local plugin = {}

plugin.core = {
    "pboettch/vim-highlight-cursor-words",
    config = function()
        vim.g.HiCursorWords_linkStyle='VisualNOS'
    end
}


return plugin
