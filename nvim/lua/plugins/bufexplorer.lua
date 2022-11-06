local plugin = {}

plugin.core = {
    "jlanzarotta/bufexplorer",
    as = "bufexplorer",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "b", "e" },
        action = ':ToggleBufExplorer<cr>',
        short_desc = "Show Buffers",
    })

    mappings.register({
        mode = "n",
        key = { "b", "j" },
        action = ':BufExplorerVerticalSplit<cr>',
        short_desc = "VShow Buffers",
    })

    mappings.register({
        mode = "n",
        key = { "b", "h" },
        action = ':BufExplorerHorizontalSplit<cr>',
        short_desc = "VShow Buffers",
    })
end
return plugin
