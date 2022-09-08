
local plugin = {}

plugin.core = {
    "ray-x/navigator.lua",
    opt_marker = "基于LSP的源码分析和导航工具",
   opt_enable = false,


    --as = "navigator",
    requires = {{"ray-x/guihua.lua", run = 'cd lua/fzy && make'}},


    setup = function()  -- Specifies code to run before this plugin is loaded.
    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require'navigator'.setup({
        })
    end,

}
plugin.mapping = function()

end
return plugin
