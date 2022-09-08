local plugin = {}

plugin.core = {
    "eddiebergman/nvim-treesitter-pyfold",
    opt_marker = "python的折叠",
    opt_enable = true,

    --as = "nvim-treesitter-pyfold",
    ft = { "python" },
    setup = function() -- Specifies code to run before this plugin is loaded.

    end,

    config = function() -- Specifies code to run after this plugin is loaded
        require('nvim-treesitter.configs').setup {
            pyfold = {
                enable = true,
                custom_foldtext = true -- Sets provided foldtext on window where module is active
            }
        }
    end,
}

plugin.mapping = function()

end

return plugin
