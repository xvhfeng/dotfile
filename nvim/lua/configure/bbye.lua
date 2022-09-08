local plugin = {}

plugin.core = {
    "moll/vim-bbye",
    opt_marker = "退出buffer的时候,保持当前的窗口等状态,常用在分隔屏的时候",
    as = "vim-bbye",
   opt_enable = true,

    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,
}

plugin.mapping = function()

end
return plugin
