local plugin = {}

plugin.core = {
    "hjson/vim-hjson",
    opt_marker = "高亮显示json文件",
   opt_enable = true,


    ft = { "hjson" },
    --as = "vim-hjson",
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()

end

return plugin
