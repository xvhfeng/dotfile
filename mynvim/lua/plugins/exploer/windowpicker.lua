plugin = {}
plugin.core = {

    "ten3roberts/window-picker.nvim",
    config = function()
        require'window-picker'.setup{
            -- Default keys to annotate, keys will be used in order. The default uses the
            -- most accessible keys from the home row and then top row.
            keys = '123456789',
            -- Swap windows by holding shift + letter
            swap_shift = true,
            -- Windows containing filetype to exclude
            exclude = { qf = true, aerial = true },
            -- Flash the cursor line of the newly focused window for 300ms.
            -- Set to 0 or false to disable.
            flash_duration = 300,
        }
    end
}

plugin.mapping = {
    keys = {
        {
            mode = {"n"},
            key = {"<leader>","w","w" },
            action = ":WindowPick<CR>",
            short_desc = "Choose Which Windows",
        },

        {
            mode = {"n"},
            key = {"<leader>","w","x" },
            action = ":WindowSwap<CR>",
            short_desc = "Swap Context By Windows",
        },

        {
            mode = {"n"},
            key = {"<leader>","w","r" },
            action = ":WindowSwapStay<CR>",
            short_desc = "Send Context To Window",
        },
        {
            mode = {"n"},
            key = {"<leader>", "w","q" },
            action = ":WindowZap<CR>",
            short_desc = "Close Which Windows",
        }
    }
}
--[==[
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


plugin.mapping = {
    keys = {
        {
            mode = {"n"},
            key = {"w","p" },
            action = ":lua picker() <cr>",
            expr = true,
            short_desc = "Choose Which Windows",
        }
    }
}
--]==]
return plugin
