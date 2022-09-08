local plugin = {}

plugin.core = {
    "itchyny/calendar.vim",
    opt_marker = "日期选择插件",
   opt_enable = true,


    as = "calendar",
    cmd = { "Calendar" },
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        vim.g.calendar_google_calendar = 1
        vim.g.calendar_google_task = 1
        vim.cmd("source ~/.cache/calendar.vim/credentials.vim")
    end,
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "o", "C" },
        action = ':Calendar -view=week -first_day=monday -split=vertical -position=right <cr>',
        short_desc = "Calendar",
        silent = true
    })

end
return plugin
