local plugin = {}

plugin.core = {
    "jlanzarotta/bufexplorer",
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "b", "l"},
        action = ':ToggleBufExplorer<cr>',
        short_desc = "Show Buffers"
    }, {
        mode = "n",
        key = {"<leader>", "b", "v"},
        action = ':BufExplorerVerticalSplit<cr>',
        short_desc = "VShow Buffers"
    }, {
        mode = "n",
        key = {"<leader>", "b", "s"},
        action = ':BufExplorerHorizontalSplit<cr>',
        short_desc = "Show Buffers"
    }}
}
return plugin
