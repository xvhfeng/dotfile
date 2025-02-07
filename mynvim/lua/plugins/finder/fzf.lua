local M = {}


    M.core = {
    'ibhagwan/fzf-lua',
    -- optional for icon support
    dependencies = { 'nvim-tree/nvim-web-devicons' },

    keys = {
        {
            '<leader>ff',
            function()
                require('fzf-lua').files({})
            end,
            desc = 'Find Files',
        },
        {
            '<leader>fg',
            function()
                require('fzf-lua').live_grep({})
            end,
            desc = 'Live grep file content',
        },
        {
            '<leader>ob',
            function()
                require('fzf-lua').buffers({})
            end,
            desc = 'Search opened buffers',
        },
        {
            '<leader>fh',
            function()
                require('fzf-lua').manpages({})
            end,
            desc = 'Search help manual page',
        },
        {
            '<leader>xd',
            function()
                require('fzf-lua').diagnostics_workspace({})
            end,
            desc = 'Workspae Diagnostics',
        },
        {
            '<leader>xx',
            function()
                require('fzf-lua').diagnostics_document({})
            end,
            desc = 'Document Diagnostics',
        },
    },
    
    config = function()
        -- calling `setup` is optional for customization
        require('fzf-lua').setup({
            winopts = {
                -- row = 1.0,
                -- col = 0.0,
                -- height = 0.5,
                -- width = 1.0,
                height = 0.9, -- window height
                width = 0.9, -- window width
                row = 0.45, -- window row position (0=top, 1=bottom)
                backdrop = 100,
                title = 'Searching...',
                title_pos = 'center', -- 'left', 'center' or 'right',
            },
            fzf_opts = {
                ['--ansi'] = true,
                ['--info'] = 'inline-right', -- fzf < v0.42 = "inline"
                ['--height'] = '100%',
                ['--layout'] = 'reverse-list',
                ['--border'] = 'none',
                ['--highlight-line'] = true, -- fzf >= v0.53
            },
        })
        local fzf = require('fzf-lua')

        -- 获取所有 fzf-lua 提供的命令
        local commands = {
        'files', 'live_grep', 'buffer', 'grep_cword', 'help_tags', -- 可以补充更多命令
        }

        for _, cmd in ipairs(commands) do
        vim.api.nvim_set_keymap('n', '<leader>' .. cmd, "<cmd>lua require('fzf-lua')." .. cmd .. "()<CR>", { noremap = true, silent = true })
        end
    end
}

    return M
