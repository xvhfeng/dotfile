local plugin = {}
plugin.core = {
    "bronson/vim-trailing-whitespace",
    disable = false,
    opt=false,

    --as = "vim-repeat",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

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
