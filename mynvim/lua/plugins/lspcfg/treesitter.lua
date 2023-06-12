local plugin = {}

plugin.core = {
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = {"vim", "bash", "c", "cpp", "lua", "java", "go"},
            highlight = {
                enable = true, -- false will disable the whole extension
                additional_vim_regex_highlighting = false
            },
            indent = {
                enable = true
            },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = '<CR>',
                    node_incremental = '<CR>',
                    node_decremental = '<BS>',
                    scope_incremental = '<TAB>',
                }
            },
          
           
        }
        vim.wo.foldmethod = 'expr'
        vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
        -- 默认不折叠
        vim.wo.foldlevel = 99
        vim.wo.foldenable = false

        local auto_indent = vim.api.nvim_create_augroup("AUTO_INDENT", {clear = true})
        vim.api.nvim_create_autocmd({"BufWritePost"}, {
            pattern = "*",
            group = auto_indent,
            command = 'normal! gg=G``'
        })
        

    end
}

return plugin
