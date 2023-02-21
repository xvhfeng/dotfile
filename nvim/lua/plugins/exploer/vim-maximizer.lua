plugin = {}

plugin.core = {
    'szw/vim-maximizer',
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "w", "o" },
        action = ':MaximizerToggle<cr>',
        short_desc = "开启/关闭最大化当前窗口",
    })

end
return plugin
