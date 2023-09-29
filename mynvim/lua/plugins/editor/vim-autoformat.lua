local plugin = {}

plugin.core = {
    'vim-autoformat/vim-autoformat',
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
                    desc = "C/C++ AutoFormat",
                }
            }
        }
    }
}

return plugin
