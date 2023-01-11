local plugin = {}

plugin.core = {
    "mbbill/undotree",
    cmd = 'UndotreeToggle',
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "e", "h" },
        action = ':UndotreeToggle<cr>',
        short_desc = "History Tree",
        silent = true
    })

end
return plugin
