local plugin = {}

plugin.core = {
   "francoiscabrol/ranger.vim",
    requires = {
        {"rbgrouleff/bclose.vim"},
    },

        vim.cmd [[
            let g:ranger_replace_netrw = 1
            let g:ranger_command_override = 'ranger --cmd "set show_hidden=true"'
        ]],
}

plugin.mapping = function()
    local mappings = require('core.mapping')
    mappings.register({
        mode = "n",
        key = { "<leader>", "m", "m" },
        action = ":Ranger<CR>",
        short_desc = "Open file-exp by Ranger.",
        silent = true
    })

end
return plugin
