local plugin = {}

plugin.core = {
    'phaazon/mind.nvim',
    branch = 'v2.2',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
        require'mind'.setup()
    end

}

plugin.mapping = function()



end

return plugin
