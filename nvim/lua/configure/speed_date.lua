local plugin = {}

plugin.core = {
    "tpope/vim-speeddating",
   opt_marker = "一个时间插件,可以通过c-x正确的加减日期",
   opt_enable = true,

    --as = "vim-speeddating",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()

end

return plugin
