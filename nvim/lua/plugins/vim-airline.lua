local plugin = {}

plugin.core = {
    "bling/vim-airline",
    as = "airline",
    vim.cmd [[
    let g:airline#extensions#tabline#enabled = 0
    let g:airline_section_b = '%{strftime("%Y-%m-%d %T")}'
    ]]
}

plugin.mapping = function()

end

return plugin
