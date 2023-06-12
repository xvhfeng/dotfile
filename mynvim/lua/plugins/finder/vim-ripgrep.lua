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
    keys = {{
        mode = "n",
        key = {"<leader>", "r", "r"},
        action = ':Rg <space>',
        short_desc = "grep keywords in project folder"
    }}
}

return plugin
