local plugin = {}

plugin.core = {
    "jlanzarotta/bufexplorer",
    disable = false,
   opt=false,


    as = "bufexplorer",
   
    setup = function()  -- Specifies code to run before this plugin is loaded.
       

    end,

    config = function() -- Specifies code to run after this plugin is loaded
      
    end,

}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "b" },
        action = ':ToggleBufExplorer<cr>',
        short_desc = "Show Buffers",
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "b", "v" },
        action = ':BufExplorerVerticalSplit<cr>',
        short_desc = "VShow Buffers",
    })

end
return plugin