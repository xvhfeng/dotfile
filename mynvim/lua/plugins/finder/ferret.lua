local plugin = {}

plugin.core = {"wincent/ferret"}

plugin.mapping = {
    tags = {{
        key = "<leader>rA",
        desc = "+ Search And Replace In Muilt Files"
    }},
    keys = {{
        mode = "n",
        key = {"<leader>", "r", "A", "s"},
        action = ":Ack! ",
        short_desc = "Search text in Files Into QuickFix",
        silent = true
    }, {
        mode = "n",
        key = {"<leader>", "r", "A", "r"},
        action = ":Acks /pattern/replacement/",
        short_desc = "Replace Files In QuickFix",
        silent = true
    }}

}

return plugin
