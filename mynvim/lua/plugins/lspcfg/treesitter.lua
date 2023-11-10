local plugin = {}

plugin.core = {
    "nvim-treesitter/nvim-treesitter",
    commit = "226c1475a46a2ef6d840af9caa0117a439465500",
    event = "BufReadPost",
    build = ':TSUpdate',
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            event = "VeryLazy",
            commit = "729d83ecb990dc2b30272833c213cc6d49ed5214",
        },
        {
            "nvim-tree/nvim-web-devicons",
            event = "VeryLazy",
            commit = "0568104bf8d0c3ab16395433fcc5c1638efc25d4"
        },
    },

    config = function()
        require('nvim-treesitter.configs').setup {
            ensure_installed = {"vim",
                "bash",
                "c",
                "cpp",
                "lua",
                "java",
                "go",
                "jsonc",
                "cmake",
                "dockerfile"
                --    "sql"

            },
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
            autopairs = {
                enable = true,
            },
            context_commentstring = {
                enable = true,
                enable_autocmd = false,
            },


        }
        -- vim.wo.foldmethod = 'marker'
        -- vim.wo.foldexpr = 'nvim_treesitter#foldexpr()'
        -- 默认不折叠
        -- vim.wo.foldlevel = 99
        -- vim.wo.foldenable = false

        --[[
        local auto_indent = vim.api.nvim_create_augroup("AUTO_INDENT", {clear = true})
        vim.api.nvim_create_autocmd({"BufWritePost"}, {
            pattern = "*",
            group = auto_indent,
            command = 'normal! gg=G``'
        })
        --]]


    end
}

return plugin
