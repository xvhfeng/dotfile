plugin = {}

plugin.core = {'szw/vim-maximizer'}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>wo",
            action = '<cmd>MaximizerToggle<cr>',
            desc = "Toggle Window Maxsize"
        }
    }
}

return plugin
