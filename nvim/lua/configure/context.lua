local plugin = {}

plugin.core = {
    "wellle/context.vim",
    opt_marker = "移动文件的时候,根据代码关键字自动压缩代码段",
   opt_enable = true,


    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}

plugin.mapping = function()

end
return plugin