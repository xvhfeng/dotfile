local plugin = {}

plugin.core = {
    "xvhfeng/neoterm.nvim",

    config = function()
        require('neoterm').setup({
            clear_on_run = true, -- run clear command before user specified commands
            mode = 'popup', -- vertical/horizontal/fullscreen
            noinsert = false, -- disable entering insert mode when opening the neoterm window
            init_when_enter = true,
            init_file = "~/.bash_profile"
        })
    end
}

plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = {"<leader>", "t", "o"},
            action = ':NeotermToggle<cr>',
            short_desc = "NeotermToggle"
        }, {
            mode = "n",
            key = {"<leader>", "t", "e"},
            action = ':NeotermExit<cr>',
            short_desc = "NeotermExit"
        }
    }
}

return plugin
