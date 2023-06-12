local plugin = {}

plugin.core = {
    "iberianpig/tig-explorer.vim",
    dependencies = {{"rbgrouleff/bclose.vim"}}
}

plugin.mapping = {
    tags = {{
        key = "<leader>gt",
        desc = "+ Tig Explorer"
    }},
    keys = {{
        mode = "n",
        key = {"<leader>", "g", "t", "c"},
        action = ":TigOpenCurrentFile<CR>",
        short_desc = "Open Current File."
    }, {
        mode = "n",
        key = {"<leader>", "g", "t", "d"},
        action = ":TigOpenProjectRootDir<CR>",
        short_desc = "Open Current Folder."
    }, {
        mode = "n",
        key = {"<leader>", "g", "t", "r"},
        action = ":TigGrepResume<CR>",
        short_desc = "Git Grep Resume."
    }, {
        mode = "n",
        key = {"<leader>", "g", "t", "g"},
        action = ":TigGrep<CR>",
        short_desc = "Git Grep."
    }, {
        mode = "n",
        key = {"<leader>", "g", "t", "b"},
        action = ":TigBlame<CR>",
        short_desc = "Git Blame."
    }, {
        mode = "n",
        key = {"<leader>", "g", "t", "t"},
        action = ":Tig<CR>",
        short_desc = "Git Blame."
    }}
}

return plugin
