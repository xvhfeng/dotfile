local plugin = {}

plugin.core = {
    "terryma/vim-expand-region",
    as = "expand-region",
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "+" },
        action = 'expand_region_expand',
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "-" },
        action = 'expand_region_shrink',
        silent = true
    })

end
return plugin
