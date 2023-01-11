
local plugin = {}

plugin.core = {
    "xvhfeng/neoterm.nvim",

    require('neoterm').setup({
        clear_on_run = true, -- run clear command before user specified commands
        mode = 'popup',   -- vertical/horizontal/fullscreen
        noinsert = false,     -- disable entering insert mode when opening the neoterm window
        init_when_enter = true,
        init_file = "~/.bash_profile",
    })
}



plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = {"<leader>", "t","o"},
        action = ':NeotermToggle<cr>',
        short_desc = "NeotermToggle",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "t","e"},
        action = ':NeotermExit<cr>',
        short_desc = "NeotermExit",
        silent = true
    })
end
return plugin
