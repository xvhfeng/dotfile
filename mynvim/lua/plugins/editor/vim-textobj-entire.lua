local plugin = {}

plugin.core = {"kana/vim-textobj-entire",
dependencies = {{"kana/vim-textobj-user"}},
}

plugin.mapping = {
    keymaps = {
        {
            tag = { key = "<leader>ef", name = "Format" },
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>efa",
                    action = '=ae',
                    desc = "Entry Format"
                }
            }
        }
    }
}

return plugin
