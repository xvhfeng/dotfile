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
    keymaps = {
         {
            tag = {key = "<leader>ef", name = "Format"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>efl",
                    action = '<cmd>call LuaFormat()<CR>',
                    desc = "Lua Format",

                }
            }
        }
    }
}

return plugin
