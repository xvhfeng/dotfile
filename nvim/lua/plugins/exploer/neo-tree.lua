local plugin = {}

plugin.core = {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "NeoTreeFocusToggle",
    requires = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        's1n7ax/nvim-window-picker',
    },

    require('neo-tree').setup({
        window = {
            mappings = {
                ["o"] = "open",
                ["s"] = "open_split",
                ["i"] = "open_vsplit",
                ["ma"] = "add",
                ["md"] = "delete",
                ["mm"] = "move",
                ["mc"] = "copy",
                ["mp"] = "paste_from_clipboard",
            },
        },
        filesystem = {
            -- follow_current_file = true,
            filtered_items = {
                visible = true,
            },
            hijack_netrw_behavior = "open_default",
        },
    }),

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
        key = {"\\" },
        action = ':NeoTreeFocusToggle<CR>',
        short_desc = "Open Floder Tree",
    })

    keymap.register({
        mode = {"n"},
        key = {"|" },
        action = ':NeoTreeShowToggle<CR>',
        short_desc = "Open Floder Tree",
    })

    keymap.register({
        mode = {"n"},
        key = {"w","q" },
        action = ":lua picker() <cr>",
        expr = true,
        short_desc = "Choose Which Windows",
    })


end



return plugin
