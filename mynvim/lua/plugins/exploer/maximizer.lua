plugin = {}

plugin.core = {'szw/vim-maximizer'}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>","w", "o"},
        action = ':MaximizerToggle<cr>',
        short_desc = "开启/关闭最大化当前窗口"
    }}
}
return plugin
