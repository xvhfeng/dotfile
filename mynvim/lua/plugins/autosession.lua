local plugin = {}

plugin.core = {
    'rmagatti/auto-session',
    config = function()
        require("auto-session").setup {
            log_level = "error",
            auto_session_root_dir = "~/.config/awesome/sessions/",
        }
    end
}

plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = {"<leader>", "s", "o"},
            action = ':SessionRestore<CR>',
            short_desc = "Load Session"
        }, {
            mode = "n",
            key = {"<leader>", "s", "b"},
            action = ':SessionRestore ',
            short_desc = "Restore Session From"
        }, {
            mode = "n",
            key = {"<leader>", "s", "D"},
            action = ':SessionDelete<CR>',
            short_desc = "Delete Session"
        }, {
            mode = "n",
            key = {"<leader>", "s", "f"},
            action = ':Autosession search<CR>',
            short_desc = "Find Sessions"
        }, {
            mode = "n",
            key = {"<leader>", "s", "d"},
            action = ':Autosession delete<CR>',
            short_desc = "Delete Session From"
        }, {
            mode = "n",
            key = {"<leader>", "s", "s"},
            action = ':SessionSave<CR>',
            short_desc = "Save Session"
        }
    }
}

return plugin
