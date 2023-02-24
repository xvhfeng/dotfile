local plugin = {}

plugin.core = {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons' },

    config = function()
        require('lualine').setup({
            sections = {
                lualine_a = {
                    {
                        'datetime',
                        -- options: default, us, uk, iso, or your own format string ("%H:%M", etc..)
                        style = 'default'
                    }
                }
            }
        })

    end
}

plugin.mapping = function()

end

return plugin
