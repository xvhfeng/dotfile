local plugin = {}

plugin.core = {
    "terryma/vim-multiple-cursors",
    opt_marker = "多光标选择文本对象,并可以进行编辑",
   opt_enable = false,


    --as = "vim-multiple-cursors",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}

plugin.mapping = function()

end
return plugin
