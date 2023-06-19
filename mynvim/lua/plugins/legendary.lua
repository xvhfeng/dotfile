local plugin = {}

plugin.core = {
    "mrjones2014/legendary.nvim",
    dependencies = {
        "kkharji/sqlite.lua",
        name = "sqlite3"
    },

    --setup function called in the keymapping.lua
}

return plugin
