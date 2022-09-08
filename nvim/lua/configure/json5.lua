local plugin = {}

plugin.core = {
    "GutenYe/json5.vim",
    opt_marker = "json5的高亮显示",
   opt_enable = true,


    as = "json5",
    ft = { "json5" },
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()

end

return plugin
