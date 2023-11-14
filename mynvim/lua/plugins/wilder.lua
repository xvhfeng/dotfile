local plugin = {}

local function fixed()
    -- update remote plugins to make wilder work
    local UpdatePlugs = vim.api.nvim_create_augroup("UpdateRemotePlugs", {})
    vim.api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
        pattern = "*",
        group = UpdatePlugs,
        command = "runtime! plugin/rplugin.vim",
    })
    vim.api.nvim_create_autocmd({ "VimEnter", "VimLeave" }, {
        pattern = "*",
        group = UpdatePlugs,
        command = "silent! UpdateRemotePlugins",
    })
end

plugin.core = {
    'gelguy/wilder.nvim',
    dependencies = {
        'roxma/nvim-yarp'
    },
    config = function()
        local wilder = require('wilder')
        wilder.set_option('use_python_remote_plugin', 0)
        wilder.setup({modes = {':', '/', '?'}})

        wilder.set_option('pipeline', {
            wilder.branch(
                wilder.cmdline_pipeline({
                    -- sets the language to use, 'vim' and 'python' are supported
                    language = 'python',
                    -- 0 turns off fuzzy matching
                    -- 1 turns on fuzzy matching
                    -- 2 partial fuzzy matching (match does not have to begin with the same first letter)
                    fuzzy = 1,
                }),
                wilder.python_search_pipeline({
                    -- can be set to wilder#python_fuzzy_delimiter_pattern() for stricter fuzzy matching
                    pattern = wilder.python_fuzzy_pattern(),
                    -- omit to get results in the order they appear in the buffer
                    sorter = wilder.python_difflib_sorter(),
                    -- can be set to 're2' for performance, requires pyre2 to be installed
                    -- see :h wilder#python_search() for more details
                    engine = 're',
                })
            ),
        })

        fixed()
    end
}

return plugin
