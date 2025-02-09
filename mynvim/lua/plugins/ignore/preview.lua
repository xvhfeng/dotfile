local plugin = {}

plugin.core = {
    'rmagatti/goto-preview',
    config = function()
        require('goto-preview').setup {}
    end

}

plugin.mapping = {

    keymaps = {
        {
            tag = {key = "<leader>fp", name = "Goto Preview"},
            keymaps = {
                {
                    mode = "n",
                    key = "<leader>fpd",
                    action = "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
                    desc = "Preview definition"
                }, {
                    mode = "n",
                    key = "<leader>fpt",
                    action = "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
                    desc = "Preview type definition"
                }, {
                    mode = "n",
                    key = "<leader>fpi",
                    action = "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
                    desc = "Preview implementation"
                }, {
                    mode = "n",
                    key = "<leader>fpc",
                    action = "<cmd>lua require('goto-preview').close_all_win()<CR>",
                    desc = "Close all preview"
                }, {
                    mode = "n",
                    key = "<leader>fpr",
                    action = "<cmd>lua require('goto-preview').references()<CR>",
                    desc = "Preview references"
                }}
        }

    }
}



return plugin
