local plugin = {}

plugin.core = {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate',
    require('nvim-treesitter.configs').setup {
        ensure_installed = { "vim","help","bash","c","cpp","lua","java","go"},
        highlight = {
            enable = true, -- false will disable the whole extension
            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>", -- set to `false` to disable one of the mappings
                node_incremental = "<CR>",
                scope_incremental = "<BS>",
                node_decremental = "<TAB>",
            },
        },
        indent = {
            enable = true
        },
        vim.cmd[[
        set foldmethod=expr
        set foldexpr=nvim_treesitter#foldexpr()
        set nofoldenable                     " Disable folding at startup.
        ]]
    }
}

return plugin
