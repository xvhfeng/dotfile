local plugin = {}

plugin.core = {
    'vladdoster/remember.nvim',
    config = function()
        vim.g.remember_open_folds = true
        vim.g.remember_dont_center = true
        require("remember").setup {
            -- for example, open_folds is off by default, use this to turn it on
            open_folds = true,
        }
    end
}

return plugin
