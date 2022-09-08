local plugin = {}

plugin.core = {
    "terryma/vim-expand-region",
    opt_marker = "块状编辑文本",
   opt_enable = true,


    as = "expand-region",
   
    setup = function()  -- Specifies code to run before this plugin is loaded.
       

    end,

    config = function() -- Specifies code to run after this plugin is loaded
      
    end,

}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "+" },
        action = 'expand_region_expand',
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "-" },
        action = 'expand_region_shrink',
        silent = true
    })

end
return plugin