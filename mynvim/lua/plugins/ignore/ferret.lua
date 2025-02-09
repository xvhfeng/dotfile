local plugin = {}

plugin.core = {"wincent/ferret"}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>fm", name = "Search In MuiltFiles"},
            keymaps = {{
                mode = "n",
                key = "<leader>fms",
                action = ":Ack! [pattern]",
                desc = "Search [pattern] in Files Into QuickFix",
            },{
                    mode = "n",
                    key = "<leader>fmc",
                    action = ":Ack! <cword><CR>",
                    desc = "Search CWORD in Files Into QuickFix",
                }, {
                    mode = "n",
                    key = "<leader>fmr",
                    action = ":Acks /pattern/replacement/",
                    desc = "Replace Files In QuickFix",
                }, {
                    mode = "n",
                    key = "<leader>fmp",
                    action = ":Acks /<cword>/replacement/",
                    desc = "Replace Files In QuickFix",
                }
            }
        }
    }
}

return plugin
