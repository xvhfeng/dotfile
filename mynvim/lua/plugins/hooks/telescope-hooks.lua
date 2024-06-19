local plugin = {}

plugin.core = {only_hooks = true}

plugin.hooks_init = function()
    local actions = require("telescope.actions")
    local trouble = require("trouble.providers.telescope")

    local telescope = require("telescope")

    telescope.setup {
        defaults = {
            mappings = {
                i = { ["<c-t>"] = require("trouble.sources.telescope").open() },
                n = { ["<c-t>"] = require("trouble.sources.telescope").open()},
            },
        },
    }
end

return plugin
