local plugin = {}

plugin.core = {
    "glacambre/firenvim",
    opt_marker = "把你的浏览器变成Neovim客户端",
   opt_enable = false,


    --as = "firenvim",
    run = function() vim.fn['firenvim#install'](0) end,
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}


plugin.mapping = function()

end
return plugin
