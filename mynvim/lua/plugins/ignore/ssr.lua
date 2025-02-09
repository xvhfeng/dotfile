local plugin = {}

plugin.core = {
    "cshuaimin/ssr.nvim",
    module = "ssr",
    -- Calling setup is optional.
    config = function()
        require("ssr").setup {
            border = "rounded",
            min_width = 50,
            min_height = 5,
            max_width = 120,
            max_height = 25,
            keymaps = {
                close = "q",
                next_match = "n",
                prev_match = "N",
                replace_confirm = "<cr>",
                replace_all = "<leader><cr>",
            },
        }
    end
}

function open_ssr()
    require("ssr").open()
end

--[[
plugin.mapping = {
    keys = {
        {
            mode = {"n",'x'},
            key = {"<leader>","s","r" },
            action = ":lua open_ssr()<cr>",
            desc = "Pattern Replace",
        },
    }
}
--]]

return plugin
