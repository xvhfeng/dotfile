local plugin = {}

plugin.core = {
    "preservim/nerdcommenter",
    init = function() -- Specifies code to run before this plugin is loaded.
        vim.g.NERDCreateDefaultMappings = 0
        vim.g.NERDCustomDelimiters = {
            json = {
                left = '// '
            },
            json5 = {
                left = '// '
            },
            hjson = {
                left = '// '
            }
        }
    end
}

plugin.mapping = {
    keys = {{
        mode = {"n", "v"},
        key = {"<leader>", "e", "c", "c"},
        action = "<Plug>NERDCommenterAlignBoth",
        short_desc = "Comment",
    }, {
        mode = {"n", "v"},
        key = {"<leader>", "e", "c", "a"},
        action = "<Plug>NERDCommenterAltDelims",
        short_desc = "Comment Alt Format",
    }, {
        mode = {"n", "v"},
        key = {"<leader>", "e", "c", "A"},
        action = "<Plug>NERDCommenterAppend",
        short_desc = "Comment Append",
    }, {
        mode = {"n", "v"},
        key = {"<leader>", "e", "c", "u"},
        action = "<Plug>NERDCommenterUncomment",
        short_desc = "UnComment",
    }}
}

return plugin
