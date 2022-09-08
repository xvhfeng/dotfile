local plugin = {}

plugin.core = {
    "vim-scripts/auto_mkdir",
    opt_marker = "save的时候自动创建目录",
   opt_enable = true,

    as = "Auto_Mkdir",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,
}

plugin.mapping = function()

end

return plugin