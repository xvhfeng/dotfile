local plugin = {}

plugin.core = {
    "jlanzarotta/bufexplorer",
    as = "bufexplorer",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "b" },
        action = ':ToggleBufExplorer<cr>',
        short_desc = "Show Buffers",
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "v" },
        action = ':BufExplorerVerticalSplit<cr>',
        short_desc = "VShow Buffers",
    })

end
return plugin
