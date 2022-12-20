local plugin = {}

plugin.core = {
    "akinsho/toggleterm.nvim",
    config = function() 
        local ok, toggleterm = pcall(require, "toggleterm")
        if not ok then
            return
        end

        toggleterm.setup {
            insert_mappings = false,
            env = {
                MANPAGER = "less -X",
            },
            terminal_mappings = false,
            start_in_insert = false,
            open_mapping = [[<space>t]],
            highlights = {
                CursorLineSign = { link = "DarkenedPanel" },
                Normal = { guibg = "#14141A" },
            },
        }

        -- Remove WinEnter to allow moving a toggleterm to new tab
        vim.cmd.autocmd { "ToggleTermCommands", "WinEnter", bang = true }
    end,
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    function _G.set_terminal_keymaps()
        local opts = {noremap = true}
        vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', 'jk', [[<C-\><C-n>]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
        vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
    end
    vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

end

return plugin
