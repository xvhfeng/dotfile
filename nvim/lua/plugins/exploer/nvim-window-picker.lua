plugin = {}

plugin.core = {
    's1n7ax/nvim-window-picker',

--    tag = 'v1.*',
    config = function()
        require('window-picker').setup({
            autoselect_one = true,
            include_current = false,
            selection_chars = '1234567890',
            filter_rules = {
                -- filter using buffer options
                bo = {
                    -- if the file type is one of following, the window will be ignored
                    filetype = { 'neo-tree', "neo-tree-popup", "notify" },

                    -- if the buffer type is one of following, the window will be ignored
                    buftype = { 'terminal', "quickfix" },
                },
            },
            other_win_hl_color = '#e35e4f',
        })
    end,

}

function picker()
    local picker = require('window-picker')
    local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(picked_window_id)
end

plugin.mapping = function()
    local keymap = require('core.keymapping')
    keymap.register({
        mode = {"n"},
        key = {"w","p" },
        action = ":lua picker() <cr>",
        expr = true,
        short_desc = "Choose Which Windows",
    })


end

return plugin
