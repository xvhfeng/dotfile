local plugin = {}

plugin.core = {
    "jamestthompson3/nvim-remote-containers",
    config = function()
    end
}
        --[[
plugin.mapping = {
    keys = { {
        mode = "n",
        key = {"<leader>", "f", "A"},
        action = ':call LuaFormat()<CR>',
        short_desc = "Format Lua File",
    }
    }
}

        --]]
return plugin
