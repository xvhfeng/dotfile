local plugin = {}

plugin.core = {
    'andrejlevkovitch/vim-lua-format',
    --"jeanlucthumm/nvim-lua-format",

    config = function()
    end
}
plugin.mapping = {
    keys = { {
        mode = "n",
        key = {"<leader>", "f", "A"},
        action = ':call LuaFormat()<CR>',
        short_desc = "Format Lua File",
    }
    }
}

return plugin
