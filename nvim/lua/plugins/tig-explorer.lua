local plugin = {}

plugin.core = {
    "iberianpig/tig-explorer.vim",

    requires = {
        {"rbgrouleff/bclose.vim"},
    },
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    -- quit
    mappings.register({
        mode = "n",
        key = { "<leader>", "t" ,"f"},
        action = ":TigOpenCurrentFile<CR>",
        short_desc = "Open Current File.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "t" ,"d"},
        action = ":TigOpenProjectRootDir<CR>",
        short_desc = "Open Current Folder.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "t" ,"r"},
        action = ":TigGrepResume<CR>",
        short_desc = "Git Grep Resume.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "t", "g" },
        action = ":TigGrep<CR>",
        short_desc = "Git Grep.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "t", "b" },
        action = ":TigBlame<CR>",
        short_desc = "Git Blame.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "<leader>", "t", "t" },
        action = ":Tig<CR>",
        short_desc = "Git Blame.",
        silent = true
    })

end
return plugin
