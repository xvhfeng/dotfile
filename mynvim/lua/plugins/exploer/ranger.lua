
local plugin = {}

plugin.core = {
    "francoiscabrol/ranger.vim",
    dependencies = {
        {"rbgrouleff/bclose.vim"},
    },

    vim.cmd [[
            let g:ranger_replace_netrw = 1
            let g:ranger_command_override = 'ranger --cmd "set show_hidden=true"'
            ]],
}

plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = { "<leader>", "f", "'" },
            action = ":Ranger<CR>",
            short_desc = "Open file-exp by Ranger.",
        }
    }
}


return plugin
