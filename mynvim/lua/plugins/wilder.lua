local plugin = {}

plugin.core = {
    'gelguy/wilder.nvim',
    build = ':UpdateRemotePlugins',
    event = 'VeryLazy',
    dependencies = {
        'roxma/nvim-yarp'
    },
    config = function()
        local wilder = require('wilder')
        wilder.setup( { next_key = '<Tab>',{ modes = { ':', '/' , '?'} } } )
    
      
        local highlighters = {
            wilder.pcre2_highlighter(),
            wilder.basic_highlighter(),
        }
    

        local popupmenu_renderer = wilder.popupmenu_renderer(wilder.popupmenu_border_theme({
            border = 'rounded',
            pumblend = 0,
            empty_message = wilder.popupmenu_empty_message_with_spinner(),
            highlighter = highlighters,
            highlights = {
                accent = wilder.make_hl(
                    'WilderAccent',
                    'Pmenu',
                    { { a = 1 }, { a = 1 }, { foreground = '#f4468f' } }
                ),
            },
            left = { ' ', wilder.popupmenu_devicons() },
            right = { ' ', wilder.popupmenu_scrollbar() },
        }))

        local wildmenu_renderer = wilder.wildmenu_renderer({
            highlighter = highlighters,
            -- separator = ' · ',
             left = { ' ', wilder.wildmenu_spinner(), ' ' },
             right = { ' ', wilder.wildmenu_index() },
        })

        wilder.set_option(
            'renderer',
            wilder.renderer_mux({
                [':'] = popupmenu_renderer,
                ['/'] = wildmenu_renderer,
            })
        )
        -- 禁用在普通模式（n）下空格触发补全
    end
}

return plugin
