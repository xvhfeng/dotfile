local plugin = {}

plugin.core = {'skywind3000/vim-preview'}

--[[ 
plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"p","q"},
        action = ':PreviewQuickfix<cr>',
        short_desc = "PreviewQuickfix"
    }, {
        mode = "n",
        key = {"q","q"},
        action = ':PreviewClose<cr>',
        short_desc = "PreviewClose"
    }}
}
--]]

plugin.mapping = function()
    vim.cmd[[
    autocmd FileType qf nnoremap <silent><buffer> p :PreviewQuickfix<cr>
    autocmd FileType qf nnoremap <silent><buffer> q :PreviewClose<cr>
    ]]
end

return plugin

