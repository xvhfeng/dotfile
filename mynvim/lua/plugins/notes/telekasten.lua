local plugin = {}

plugin.core = {
    'renerocksai/telekasten.nvim',
    dependencies = {
        {'renerocksai/calendar-vim'},
        {'nvim-telescope/telescope-media-files.nvim'},
    },

}


return plugin
