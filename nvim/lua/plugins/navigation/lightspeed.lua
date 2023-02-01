local plugin = {}

plugin.core = {
    'ggandor/lightspeed.nvim',
    as = 'lightspeed',

    setup = function()
        require'lightspeed'.setup{}
    end
}

plugin.mapping = function()
    local mappings = require('core.keymapping')

    mappings.register({
        mode = "n",
        key = {"L"},
        noremap = true,
        action = '<Plug>Lightspeed_s',
        short_desc = "back by jump to lines"
    })

    mappings.register({
        mode = "n",
        key = {"H"},
        noremap = true,
        action = '<Plug>Lightspeed_S',
        short_desc = "jump to lines"
    })



end
return plugin

