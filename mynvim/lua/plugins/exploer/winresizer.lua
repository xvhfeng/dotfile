local plugin = {}

plugin.core = {
    'simeji/winresizer',
    config = function() vim.g.winresizer_gui_enable = 1 end
}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader>ws",
            action = "<cmd>WinResizerStartResize<cr>",
            desc = "Resize Windows"
        }
    }
}

--[[
Start 'window resize mode', and you can resize current vim windows using 'h', 'j', 'k', 'l' keys
You want to finish resize mode, then press "Enter" key
If you cancel window resize, then press "q" key. You will get window size of before change
You can change the mode if you press "e" in 'window resize mode'
----]]
return plugin
