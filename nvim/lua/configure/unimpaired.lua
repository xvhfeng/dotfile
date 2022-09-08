local plugin = {}

plugin.core = {
    "tpope/vim-unimpaired",
   opt_marker = "[ ] 开头的快捷键,vim缺失的快捷键",
   opt_enable = true,

    as = "Unimpaired",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,
}

plugin.mapping = function()

end

return plugin