local plugin = {}

plugin.core = {
    "jremmen/vim-ripgrep",

    vim.cmd ([[
    let g:rg_highlight = 1
    let g:rg_derive_root = 1
    let g:rg_root_types = ['.git','.svn','.root','.project']
    ]])
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "r","r" },
        action = ':Rg <space>',
        short_desc = "grep keywords in project folder",
    })
end

return plugin
