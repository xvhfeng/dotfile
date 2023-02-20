local plugin = {}

plugin.core = {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "NeoTreeFocusToggle",
    requires = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons",
        "MunifTanjim/nui.nvim",
        {
            -- only needed if you want to use the commands with "_with_window_picker" suffix
            's1n7ax/nvim-window-picker',
            tag = "v1.*",
            config = function()
                require'window-picker'.setup({
                    autoselect_one = true,
                    include_current = false,
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
    },
}
plugin.config = function()
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
            hijack_netrw_behavior = "open_current",
        },
    })
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

    --[[
    keymap.register({
        mode = {"n"},
        key = {"<leader>","w","w" },
        action = function()
            picker = require('window-picker')
            picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
            vim.api.nvim_set_current_win(picked_window_id)
        end, 
        expr = true,
        short_desc = "Open Floder Tree",
    })
    --]]


end



return plugin
