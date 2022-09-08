local plugin = {}

plugin.core = {
    "houtsnip/vim-emacscommandline",
    opt_marker = "通过添加emacs的按键映射,使命令行更强bash的命令行,类似的插件有:vim-rsi ",
   opt_enable = true,


    --as = "vim-emacscommandline",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}

plugin.mapping = function()

end
return plugin
