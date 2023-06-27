local plugin = {}

plugin.core = {
    "luochen1990/rainbow",

    init = function() -- Specifies code to run before this plugin is loaded.
            vim.g.rainbow_active = 1
    end,
}

return plugin
