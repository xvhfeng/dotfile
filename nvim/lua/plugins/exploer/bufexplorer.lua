
local plugin = {}

plugin.core = {
    "jlanzarotta/bufexplorer",
    as = "bufexplorer",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "e" },
        action = ':ToggleBufExplorer<cr>',
        short_desc = "Show Buffers",
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "j" },
        action = ':BufExplorerVerticalSplit<cr>',
        short_desc = "VShow Buffers",
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "s" },
        action = ':BufExplorerHorizontalSplit<cr>',
        short_desc = "Show Buffers",
    })
end
return plugin
