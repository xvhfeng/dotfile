local plugin = {}

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
    keymaps = {
        {
            mode = "n",
            key = "<leader>ww",
            action = "<cmd>WindowPick<CR>",
            desc = "Choose Which Windows",
        },

        {
            mode = "n",
            key = "<leader>wx",
            action = "<cmd>WindowSwap<CR>",
            desc = "Swap Context By Windows",
        },

        {
            mode = "n",
            key = "<leader>wr",
            action = "<cmd>WindowSwapStay<CR>",
            desc = "Send Context To Window",
        },
        {
            mode = "n",
            key = "<leader>wc",
            action = "<cmd>WindowZap<CR>",
            desc = "Close Which Windows",
        }
    }
}

return plugin
