
local plugin = {}

plugin.core = {
    "ray-x/navigator.lua",

    --as = "navigator",
    requires = {{"ray-x/guihua.lua", run = 'cd lua/fzy && make'}},


    config = function() -- Specifies code to run after this plugin is loaded
        require'navigator'.setup({
        })
    end,

}
return plugin
