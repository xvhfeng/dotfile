local plugin = {}

plugin.core = {
    "mbbill/undotree",
    cmd = 'UndotreeToggle',
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "h", "t" },
        action = ':UndotreeToggle<cr>',
        short_desc = "History Tree",
        silent = true
    })

end
return plugin
