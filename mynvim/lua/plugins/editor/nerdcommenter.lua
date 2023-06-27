local plugin = {}

plugin.core = {
    "preservim/nerdcommenter",
    init = function() -- Specifies code to run before this plugin is loaded.
        vim.g.NERDCreateDefaultMappings = 0
        vim.g.NERDCustomDelimiters = {
            json = {left = '// '},
            json5 = {left = '// '},
            hjson = {left = '// '}
        }
    end
}

plugin.mapping = {
    keymaps = {
         {
            tag = {key = "<leader>ec", name = "Commneter"},
            keymaps = {
                {
                    mode = {"n", "v"},
                    key = "<leader>ecc",
                    action = "<Plug>NERDCommenterAlignBoth",
                    desc = "Comment"
                }, {
                    mode = {"n", "v"},
                    key = "<leader>ecd",
                    action = "<Plug>NERDCommenterAltDelims",
                    desc = "Comment Alt Format"
                }, {
                    mode = {"n", "v"},
                    key = "<leader>eca",
                    action = "<Plug>NERDCommenterAppend",
                    desc = "Comment Append"
                }, {
                    mode = {"n", "v"},
                    key = "<leader>ecu",
                    action = "<Plug>NERDCommenterUncomment",
                    desc = "UnComment"
                }
            }
        }
    }
}

return plugin
