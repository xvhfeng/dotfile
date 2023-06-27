local plugin = {}

plugin.core = {"jlanzarotta/bufexplorer"}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>bb",
            action = '<cmd>ToggleBufExplorer<cr>',
            desc = "Show Buffers"
        }, {
            mode = "n",
            key = "<leader>bv",
            action = '<cmd>BufExplorerVerticalSplit<cr>',
            desc = "Show Buffers Vert"
        }, {
            mode = "n",
            key = "<leader>bs",
            action = '<cmd>BufExplorerHorizontalSplit<cr>',
            desc = "Show Buffers Hori"
        }
    }
}

return plugin
