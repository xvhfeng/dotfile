local plugin = {}

plugin.core = {

    -- dir = '/opt/lib/vim-cpplint',
    'xvhfeng/vim-cpplint',
    config  = function()
        vim.cmd [[
            " autocmd BufWritePost *.h,*.cpp call Cpplint()
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
                    key = "<leader>efl",
                    action = '<cmd>call Cpplint()<cr>',
                    desc = "C/C++ Cpplint Format",
                }
            }
        }
    }
}

return plugin
