local plugin = {}

plugin.core = {
    'andrejlevkovitch/vim-lua-format',
    -- not try,if vim-lua-format is not work,try it
    -- and install stylua:cargo install stylua , JohnnyMorganz/StyLua
    -- "wesleimp/stylua.nvim", 

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
