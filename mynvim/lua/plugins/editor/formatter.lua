local plugin = {}

plugin.core = {
    "rhysd/vim-clang-format",
}

plugin.mapping = {
    keys = {{
        mode = "n",
        key = {"<leader>", "f", "a"},
        action = ':ClangFormat<cr>',
        short_desc = "Format File",
    } }
}

return plugin
