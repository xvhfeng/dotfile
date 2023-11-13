local plugin = {}

plugin.core = {
    "mrjones2014/legendary.nvim",
    dependencies = {{
        "kkharji/sqlite.lua",
        name = "sqlite3"
    }, "stevearc/dressing.nvim"},

    config = function()
        require('legendary').setup({require('dressing').setup({
            select = {
                get_config = function(opts)
                    if opts.kind == 'legendary.nvim' then
                        return {
                            telescope = {
                                sorter = require('telescope.sorters').fuzzy_with_index_bias({})
                            }
                        }
                    else
                        return {}
                    end
                end
            }
        })})
    end
    -- setup function called in the keymapping.lua
}

plugin.mapping = {
    keymaps = {
        {
            mode = "n",
            key = "<leader><space>",
            action = "<cmd>:Legendary<CR>",
            desc = "Open Legendary"
        }}
}
return plugin
