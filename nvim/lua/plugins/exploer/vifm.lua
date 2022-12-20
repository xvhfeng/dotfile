local plugin = {}

plugin.core = {
   "vifm/vifm.vim",

        vim.cmd [[
        ]],
}

plugin.mapping = function()
    local mappings = require('core.keymapping')
    mappings.register({
        mode = "n",
        key = { "m", "b" },
        action = ":EditVifm<CR>",
        short_desc = "Open file-exp by vifm.",
        silent = true
    })

    mappings.register({
        mode = "n",
        key = { "n", "m" },
        action = ":PeditVifm<CR>",
        short_desc = "Open file-exp by vifm in preview mode.",
        silent = true
    })
    mappings.register({
        mode = "n",
        key = { "n", "h" },
        action = ":SplitVifm<CR>",
        short_desc = "Split window for vifm.",
        silent = true
    })
    mappings.register({
        mode = "n",
        key = { "n", "v" },
        action = ":VsplitVifm<CR>",
        short_desc = "vertically split window for vim",
        silent = true
    })

end
return plugin
