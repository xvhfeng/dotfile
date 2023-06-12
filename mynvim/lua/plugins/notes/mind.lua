local plugin = {}

plugin.core = {
    'phaazon/mind.nvim',
    branch = 'v2.2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
        require'mind'.setup()
    end

}

return plugin
