plugin = {}

plugin.core = {'wesQ3/vim-windowswap'}

function picker()
    local picker = require('window-picker')
    local picked_window_id = picker.pick_window() or vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(picked_window_id)
end


function windowswap_with_picker()
    vim.fn['WindowSwap#EasyWindowSwap']()
    picker()
    vim.fn['WindowSwap#EasyWindowSwap']()
end

plugin.mapping = {
    keys = {
        {
            mode = "n",
            key = {"<leader>", "w","m"},
            action = ':call WindowSwap#MarkWindowSwap()<cr>',
            short_desc = "Mark Changed Windows"
        },
        {
            mode = "n",
            key = {"<leader>", "w","d"},
            action = ':call WindowSwap#DoWindowSwap()<cr>',
            short_desc = "Do Change Windows"
        },
        {
            mode = "n",
            key = {"<leader>", "w","E"},
            action = ':call WindowSwap#EasyWindowSwap()<cr>',
            short_desc = "Easy To Change Windows"
        },
        {
            mode = "n",
            key = {"<leader>", "w","e"},
            action = ':lua windowswap_with_picker()<cr>',
            short_desc = "Swap Window With Picker"
        }


    }
}
return plugin

