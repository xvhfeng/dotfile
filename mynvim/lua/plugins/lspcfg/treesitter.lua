local plugin = {}

plugin.core = {
    "nvim-treesitter/nvim-treesitter",
    event = "BufReadPost",
    build = ':TSUpdate',
    dependencies = {
        {
            "JoosepAlviste/nvim-ts-context-commentstring",
            --           event = "VeryLazy",
        },
        {
            "nvim-tree/nvim-web-devicons",
            event = "VeryLazy",
        },
    },
    config = function()
        --require('ts_context_commentstring').setup {}
        require('ts_context_commentstring').setup {}
        require('nvim-treesitter.configs').setup {
            ensure_installed = {"vim",
            "bash",
            "c",
            "cpp",
            "lua",
            "java",
            "go",
            "jsonc",
            "json"
            --                "cmake",
            --               "dockerfile"
            --    "sql"

        },
        highlight = {
            enable = false, -- false will disable the whole extension
            additional_vim_regex_highlighting = false,
            disable={"error"}
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


end,
vim.g.skip_ts_context_commentstring_module = true

}

return plugin
