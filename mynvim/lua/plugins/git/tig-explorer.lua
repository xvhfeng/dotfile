local plugin = {}

plugin.core = {
    "iberianpig/tig-explorer.vim",
    dependencies = {{"rbgrouleff/bclose.vim"}}
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>ge", name = "TigExplorer"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>gef",
                    action = "<cmd>TigOpenCurrentFile<CR>",
                    desc = "Open Current File."
                }, {
                    mode = "n",
                    key = "<leader>gep",
                    action = "<cmd>TigOpenProjectRootDir<CR>",
                    desc = "Open Current Folder."
                }, {
                    mode = "n",
                    key = "<leader>ger",
                    action = "<cmd>TigGrepResume<CR>",
                    desc = "Git Grep Resume."
                }, {
                    mode = "n",
                    key = "<leader>geg",
                    action = "<cmd>TigGrep<CR>",
                    desc = "Git Grep."
                }, {
                    mode = "n",
                    key = "<leader>geb",
                    action = "<cmd>TigBlame<CR>",
                    desc = "Git Blame."
                }, {
                    mode = "n",
                    key = "<leader>get",
                    action = "<cmd>Tig<CR>",
                    desc = "Git Blame."
                }
            }
        }
    }
}

return plugin
