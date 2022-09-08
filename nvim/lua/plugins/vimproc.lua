local plugin = {}

plugin.core = {
    "Shougo/vimproc",
    disable = false,
    opt=false,

    as = "vimproc",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded

    end,
}

plugin.mapping = function()

end

return plugin