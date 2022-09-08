local plugin = {}

plugin.core = {
    "bling/vim-airline",
    disable = false,
    opt=false,

    as = "airline",
    setup = function()  -- Specifies code to run before this plugin is loaded.
        vim.cmd [[
            let g:airline#extensions#tabline#enabled = 0
            let g:airline_section_b = '%{strftime("%Y-%m-%d %T")}'
        ]]
    end,

    config = function() -- Specifies code to run after this plugin is loaded
        
    end,
}

plugin.mapping = function()

end

return plugin