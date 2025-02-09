local plugin = {}

plugin.core = {
    --   dir = "/opt/lib/vim-autoformat"

    'xvhfeng/vim-autoformat',
    branch = 'bgm-master',
    config  = function()
        vim.cmd [[
            au BufWrite * :Autoformat
            ]]
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>ef", name = "Format"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>efa",
                    action = '<cmd>Autoformat<cr>',
                    desc = "C/C++ AstyleInAutoFormat",
                }
            }
        }
    }
}

return plugin
