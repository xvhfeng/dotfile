local plugin = {}

plugin.core = {
    "Yggdroot/indentLine",
    vim.cmd ([[
        let g:indentLine_enabled = 1
        let g:indentLine_setColors = 0
        let g:indentLine_char = 'c'
        let g:indentLine_char_list = ['|', '¦', '┆', '┊']
    ]])

}

return plugin
