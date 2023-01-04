local plugin = {}

plugin.core = {
    "anuvyklack/windows.nvim",
    requires = {
       "anuvyklack/middleclass",
       "anuvyklack/animation.nvim"
    },
    config = function()
       vim.o.winwidth = 10
       vim.o.winminwidth = 10
       vim.o.equalalways = false
       require('windows').setup()
    end
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = {"<C-w>", "z" },
        action = ':WindowsMaximize<cr>',
        short_desc = "WindowsMaximize"
    })
    mappings.register({
        mode = "n",
        key = {"<C-w>", "_" },
        action = ':WindowsMaximizeVertically<cr>',
        short_desc = "WindowsMaximizeVertically"
    })
    mappings.register({
        mode = "n",
        key = {"<C-w>", "|" },
        action = ':WindowsMaximizeHorizontally<cr>',
        short_desc = "WindowsMaximizeHorizontally"
    })
    mappings.register({
        mode = "n",
        key = {"<C-w>", "=" },
        action = ':WindowsEqualize<cr>',
        short_desc = "WindowsEqualize"
    })
end


return plugin
