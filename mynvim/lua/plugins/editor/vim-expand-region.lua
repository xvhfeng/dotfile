local plugin = {}

plugin.core = {
    "terryma/vim-expand-region",
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"+"},
        action = 'expand_region_expand',
    }, {
        mode = "n",
        key = {"-"},
        action = 'expand_region_shrink',
    }}
}

return plugin
