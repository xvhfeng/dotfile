local plugin = {}
plugin.core = {
    'gelguy/wilder.nvim',
    config = function()
        local wilder = require('wilder')
        wilder.set_option('use_python_remote_plugin', 0)
        wilder.setup({modes = {':', '/', '?'}})
    end
}

return plugin
