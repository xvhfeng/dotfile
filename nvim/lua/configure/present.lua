local plugin = {}

plugin.core = {
    --"sotte/presenting.vim",
    "Chaitanyabsprip/present.nvim",
    opt_marker = "使用lua为nvim编写的ppt插件",
    opt_enable = true,

    setup = function() -- Specifies code to run before this plugin is loaded.
    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end
}

plugin.mapping = function()
end

return plugin
