local plugin = {}

plugin.core = {
    'rmagatti/auto-session',
    config = function()
        require("auto-session").setup {
            log_level = "error",
            auto_session_root_dir = "/tmp/nvim/autosession/",
        }
    end
}

plugin.mapping = {
    keymaps = {
        { tag = {key = "<leader>ss",name = "SessionMgr"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>sso",
                    action = '<cmd>SessionRestore<CR>',
                    desc = "Load Session"
                }, {
                    mode = "n",
                    key = "<leader>ssO",
                    action = ':SessionRestore [path]',
                    desc = "Restore Session From [PATH]"
                }, {
                    mode = "n",
                    key = "<leader>ssd", 
                    action = '<cmd>SessionDelete<CR>',
                    desc = "Delete Session"
                }, {
                    mode = "n",
                    key = "<leader>ssf", 
                    action = '<cmd>Autosession search<CR>',
                    desc = "Find Sessions"
                }, {
                    mode = "n",
                    key = "<leader>ssD",
                    action = ':Autosession delete [path]',
                    desc = "Delete Session From [PATH]"
                }, {
                    mode = "n",
                    key = "<leader>sss", 
                    action = '<cmd>SessionSave<CR>',
                    desc = "Save Session"
                }
            }
        }
    }
}

return plugin
