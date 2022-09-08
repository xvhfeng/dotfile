local plugin = {}

plugin.core = {
    "tpope/vim-surround",
   opt_marker = "更改一个被引号,括号等包围的符号",
   opt_enable = false,

    --as = "vim-surround",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}
plugin.mapping = function()

end
return plugin
