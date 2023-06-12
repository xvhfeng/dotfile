local plugin = {}

plugin.core = {
    "mbbill/undotree",
    cmd = 'UndotreeToggle'
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "e", "h"},
        action = ':UndotreeToggle<cr>',
        short_desc = "History Tree",
    }}
}

return plugin
