local plugin = {}

plugin.core = {
    'skywind3000/vim-preview',
}

plugin.mapping = function()
    vim.cmd[[
    autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
    autocmd FileType qf nnoremap <silent><buffer> q :PreviewClose<cr>
    ]]
end
return plugin

