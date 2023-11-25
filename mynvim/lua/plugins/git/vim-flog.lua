local plugin = {}

plugin.core = {
    "rbong/vim-flog",
    lazy = true,
    cmd = { "Flog", "Flogsplit", "Floggit" },
    dependencies = {
        "tpope/vim-fugitive",
    },

}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>gl", name = "Git Commit Log"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>glo",
                    action = "<cmd>Flog<CR>",
                    desc = "Open Git Commit Log"
                }, {
                    mode = "n",
                    key = "<leader>gls",
                    action = "<cmd>Flogsplit<CR>",
                    desc = "Split Open Git Commit Log"
                }, {
                    mode = "n",
                    key = "<leader>glg",
                    action = "<cmd>Floggit<CR>",
                    desc = "Flog Git"
                }
            }
        }
    }
}

return plugin
