local plugin = {}

plugin.core = {
    'farmergreg/vim-lastplace',
    vim.cmd([[
    let g:lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
    let g:lastplace_ignore_buftype = "quickfix,nofile,help"
    let g:lastplace_open_folds = 0
    ]])
}

return plugin
