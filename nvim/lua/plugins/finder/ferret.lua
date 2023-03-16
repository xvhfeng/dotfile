local plugin = {}

plugin.core = {
    "wincent/ferret",

    config = function() -- Specifies code to run after this plugin is loaded
    end,

}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.add_mapping_prefix("<leader>rA", {
        name = "+ Search And Replace In Muilt Files"
    })
    mappings.register({
        mode = "n",
        key = {"<leader>", "r", "A","s"},
        action = ":Ack! ",
        short_desc = "Search text in Files Into QuickFix",
        silent = true
    })


    mappings.register({
        mode = "n",
        key = {"<leader>", "r","A", "r"},
        action = ":Acks /pattern/replacement/",
        short_desc = "Replace Files In QuickFix",
        silent = true
    })

end
return plugin
