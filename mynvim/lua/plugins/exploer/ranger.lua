local plugin = {}

plugin.core = {
    "francoiscabrol/ranger.vim",
    dependencies = {{"rbgrouleff/bclose.vim"}},

    config = function()
        vim.g.ranger_replace_netrw = 1 
        vim.g.ranger_command_override = 'ranger --cmd "set show_hidden=true"'
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>we", name = "Exploer"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>wer",
                    action = "<cmd>Ranger<CR>",
                    desc = "Open Ranger."
                },
                {
                    mode = "n",
                    key = "<space>",
                    action = "<cmd>Ranger<CR>",
                    desc = "Open Ranger."
                }
            }
        }
    }
}

return plugin
