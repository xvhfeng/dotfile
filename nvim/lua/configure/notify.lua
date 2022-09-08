local plugin = {}

plugin.core = {
    "rcarriga/nvim-notify",
    opt_marker = "nvim的通知插件, 可以提示启动和任务到期等等",
    opt_enable = true,

    --as = "nvim-notify",
    setup = function()  -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        vim.notify = require("notify")
    end,
}

plugin.mapping = function()

end
return plugin
