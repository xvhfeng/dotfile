local plugin = {}

plugin.core = {
    "danymat/neogen",
    dependencies = "nvim-treesitter/nvim-treesitter",
    config = true
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>eg", name = "DoxyGen"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>ego",
                    action = "<cmd>Neogen<CR>",
                    desc = "Generate Annotation"
                }, {
                    mode = "n",
                    key = "<leader>egf",
                    action = "<cmd>Neogen func<CR>",
                    desc = "Generate Func Annotation"
                }, {
                    mode = "n",
                    key = "<leader>egc",
                    action = "<cmd>Neogen class<CR>",
                    desc = "Generate Class Annotation"
                }, {
                    mode = "n",
                    key = "<leader>egt",
                    action = "<cmd>Neogen type<CR>",
                    desc = "Generate Type Annotation"
                }, {
                    mode = "n",
                    key = "<leader>egw",
                    action = "<cmd>Neogen file<CR>",
                    desc = "Generate File Annotation"
                }
            }
        }
    }

}

return plugin
