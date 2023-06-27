local plugin = {}

plugin.core = {"mbbill/undotree", cmd = 'UndotreeToggle'}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>eh", name = "UndoTree"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>eho",
                    action = ':UndotreeToggle<cr>',
                    desc = "Toggle UndoTree"
                }
            }
        }
    }
}

return plugin
