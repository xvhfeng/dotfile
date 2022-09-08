local plugin = {}

plugin.core = {
    "AndrewRadev/linediff.vim",
    opt_marker = "linediff插件提供了一个简单的命令:linediff，用于区分两个独立的文本块中展现不一样的text",
   opt_enable = true,


    as = "linediff",
    cmd = { "Linediff" },
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,

}


plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "v",
        key = { "<leader>", "l", "d" },
        action = ":'<,'>Linediff<cr>",
        short_desc = "Line Diff",
        noremap = true,
    })

end
return plugin
