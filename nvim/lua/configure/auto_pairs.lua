local plugin = {}

plugin.core = {
    "vim-scripts/Auto-Pairs",
    opt_marker = "格式化插入括号等",
   opt_enable = true,

    as = "Auto-Pairs",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,
}

plugin.mapping = function()

end

return plugin
