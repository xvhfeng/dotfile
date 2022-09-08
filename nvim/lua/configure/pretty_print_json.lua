local plugin = {}

plugin.core = {
    "tpope/vim-jdaddy",
    opt_marker = "一个json的插件,为最外面的object添加一个key,具体的作用还没探明",
    opt_enable = true,

    --as = "vim-jdaddy",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,
}

plugin.mapping = function()
end

return plugin
