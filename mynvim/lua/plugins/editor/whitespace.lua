local plugin = {}
plugin.core = {
    'jdhao/whitespace.nvim',

    config = function()
        vim.g.trailing_whitespace_exclude_filetypes = {'alpha', 'git'}
    end
}

plugin.mapping = {
    keymaps = {
        {
            tag = {key = "<leader>ee", name = "Trailing Whitespace"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>eec",
                    action = '<cmd>StripTrailingWhitespace<cr>',
                    desc = "Clean Space"
                }
            }
        }
    }
}

return plugin
