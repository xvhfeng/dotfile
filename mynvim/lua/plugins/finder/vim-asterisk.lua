local plugin = {}

plugin.core = {'haya14busa/vim-asterisk'}

plugin.mapping = {
    keys = {
        {mode = "n", key = {"*"}, action = '<Plug>(asterisk-*)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"#"}, action = '<Plug>(asterisk-#)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"g*"}, action = '<Plug>(asterisk-g*)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"g#"}, action = '<Plug>(asterisk-g#)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"z*"}, action = '<Plug>(asterisk-z*)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"gz*"}, action = '<Plug>(asterisk-gz*)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"z#"}, action = '<Plug>(asterisk-z#)',short_desc = "No Desc" ,checked = false},
        {mode = "n", key = {"gz#"}, action = '<Plug>(asterisk-gz#)',short_desc = "No Desc" ,checked = false},
    }
}

return plugin
