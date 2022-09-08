local plugin = {}

plugin.core = {
    "norcalli/nvim-colorizer.lua",
    opt_marker = "没有外部依赖基于luajit的高亮显示",
   opt_enable = true,


    as = "nvim-colorizer",
    ft = { "lua", "vim", "html", "css", "markdown" },
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require 'colorizer'.setup()
    end,
}

plugin.mapping = function()

end
return plugin
