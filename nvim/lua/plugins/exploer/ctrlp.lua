local plugin = {}

plugin.core = {
    "kien/ctrlp.vim",
    as = "ctrlp",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
end
return plugin