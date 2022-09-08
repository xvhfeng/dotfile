local plugin = {}
plugin.core = {
    "bronson/vim-trailing-whitespace",
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "k", "l" ,"s"},
        action = ':FixWhitespace<cr>',
        short_desc = "Kill Lined Space",
    })
end
return plugin
