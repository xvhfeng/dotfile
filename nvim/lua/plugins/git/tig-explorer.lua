local plugin = {}

plugin.core = {
    "iberianpig/tig-explorer.vim",

    requires = {{"rbgrouleff/bclose.vim"}}
}

plugin.mapping = function()
    local mappings = require('core.keymapping')

    mappings.add_mapping_prefix("<leader>gt", {
        name = "+ Tig Explorer"
    })
    -- quit
    mappings.register({
        mode = "n",
        key = {"<leader>", "g", "t", "c"},
        action = ":TigOpenCurrentFile<CR>",
        short_desc = "Open Current File.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g", "t", "d"},
        action = ":TigOpenProjectRootDir<CR>",
        short_desc = "Open Current Folder.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g", "t", "r"},
        action = ":TigGrepResume<CR>",
        short_desc = "Git Grep Resume.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g", "t", "g"},
        action = ":TigGrep<CR>",
        short_desc = "Git Grep.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g", "t", "b"},
        action = ":TigBlame<CR>",
        short_desc = "Git Blame.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = {"<leader>", "g", "t", "t"},
        action = ":Tig<CR>",
        short_desc = "Git Blame.",
        silent = true
    })

end
return plugin
