local plugin = {}

plugin.core = {
    "Yggdroot/indentLine",
    config = function()
        vim.g.indentLine_enabled = 1
        vim.g.indentLine_setColors = 0
        vim.g.indentLine_char = 'c'
        vim.g.indentLine_char_list = "['|', '¦', '┆', '┊']"
    end
}

return plugin
