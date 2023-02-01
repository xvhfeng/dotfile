local plugin = {}

plugin.core = {
    -- as = "nvim-treesitter",
    'nvim-treesitter/nvim-treesitter',
    --[==[
    run = ':TSUpdate',

    -- when TSUpdate not useful,use follow command
    --]==]
    run = function()
        local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
        ts_update()
    end,


    --[[
    ---- vim.opt.foldmethod     = 'expr'
    -- vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
    ---WORKAROUND
    vim.api.nvim_create_autocmd({'BufEnter','BufAdd','BufNew','BufNewFile','BufWinEnter'}, {
    group = vim.api.nvim_create_augroup('TS_FOLD_WORKAROUND', {}),
    callback = function()
    vim.opt.foldmethod     = 'expr'
    vim.opt.foldexpr       = 'nvim_treesitter#foldexpr()'
    end
    })
    ---ENDWORKAROUND
    --]]
    setup = function() -- Specifies code to run after this plugin is loaded
        require'nvim-treesitter.configs'.setup {
            ensure_installed = {"bash",  "c",  "cpp"},
            -- Automatically install missing parsers when entering buffer
            -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
            auto_install = true,
            highlight = {
                enable = true, -- false will disable the whole extension
            },
        }

        --[[
        local parser_config = require"nvim-treesitter.parsers".get_parser_configs()
        parser_config.org = {
        install_info = {
        url = 'https://github.com/milisims/tree-sitter-org',
        revision = 'main',
        files = {'src/parser.c', 'src/scanner.cc'}
        },
        filetype = 'org'
        }
        --]]
    end

}

return plugin
