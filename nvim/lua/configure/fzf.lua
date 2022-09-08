local plugin = {}

plugin.core = {
    "ibhagwan/fzf-lua",
    opt_marker = "一个fzf的模糊查询的插件,提供 files  oldfiles等的功能",
   opt_enable = true,


    as = "fzf",
    requires = {
        {"kyazdani42/nvim-web-devicons"},
    },

    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
    end,
}

plugin.mapping = function()
    local mappings = require('core.mapping')
mappings.register({
    mode = "n",
    key = { "<leader>","b","h" },
    action = ':FzfLua oldfiles<cr>',
    short_desc = "Opened Buffer History"
})
end

return plugin
