
local plugin = {}
plugin.core = {
    "bronson/vim-trailing-whitespace",
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "e", "k" ,"s"},
        action = ':FixWhitespace<cr>',
        short_desc = "Kill Lined Space",
    })
end
return plugin
