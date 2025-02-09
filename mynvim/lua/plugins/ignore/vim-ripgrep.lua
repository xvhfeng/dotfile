local plugin = {}

plugin.core = {
    "jremmen/vim-ripgrep",

    config = function()
        vim.g.rg_highlight = 1
        vim.g.rg_derive_root = 1
        vim.g.rg_root_types = "['.git','.svn','.root','.project']"
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = '<leader>ff', name = "Simpe Rg Find"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>fff",
                    action = ':Rg <space>',
                    desc = "grep keywords in project folder"
                }, {
                    mode = "n",
                    key = "<leader>ffc",
                    action = '<cmd>Rg <CWORD><cr>',
                    desc = "grep cword in project folder"
                }

            }
        }
    }
}

return plugin
