local plugin = {}

plugin.core = {
    'xvhfeng/vim-templates',
    branch = 'bgm-master',
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>ef", name = "Format"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>efh",
                    action = '<cmd>TemplateAutoInit<cr>',
                    desc = "AutoInit HeaderInfo",
                }
            }
        }
    }
}
return plugin
