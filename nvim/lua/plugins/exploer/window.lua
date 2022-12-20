local plugin = {}

plugin.core = {
    only_keymapping
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = {"w", "s" },
        action = ':split<cr>',
        short_desc = "Split Window"
    })
end


return plugin
