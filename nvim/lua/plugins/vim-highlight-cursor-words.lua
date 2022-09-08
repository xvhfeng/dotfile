local plugin = {}

plugin.core = {
    "pboettch/vim-highlight-cursor-words",
    as = "highlight-cursor-words",
    vim.cmd [[
    let g:HiCursorWords_linkStyle='VisualNOS'
    ]]
}


return plugin
