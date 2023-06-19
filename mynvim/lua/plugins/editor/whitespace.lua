local plugin = {}
plugin.core = {
    'jdhao/whitespace.nvim',

    config = function()
        vim.g.trailing_whitespace_exclude_filetypes = {'alpha', 'git'}
    end
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>","s","c"},
        action = '<cmd>StripTrailingWhitespace<cr>',
    }
    }
}

return plugin
