local plugin = {}

plugin.core = {
    'voldikss/vim-floaterm',
    vim.cmd([[
        let g:floaterm_opener = 'edit'
    ]])
}

plugin.mapping = function()

end

return plugin
