local plugin = {}

plugin.core = {
   "francoiscabrol/ranger.vim",
    requires = {
        {"rbgrouleff/bclose.vim"},
    },

    setup = function() -- Specifies code to run before this plugin is loaded.
        vim.cmd [[
            let g:ranger_replace_netrw = 1
        ]]
       -- ranger_replace_netrw = 1,
       -- vim.g.ranger_replace_netrw = 1
       -- vim.g.neoranger_viewmode='multipane'
       --vim.cmd("let g:ranger_replace_netrw = 1")
       --vim.cmd("let g:rnvimr_enable_picker = 1")
       --vim.cmd("let g:ranger_command_override = 'ranger --cmd \"set show_hidden=true\"'")
       
    end,
}

plugin.mapping = function()
 
    local mappings = require('core.mapping')
    -- quit
    mappings.register({
        mode = "n",
        key = { "<leader>", "m", "m" },
        action = ":Ranger<CR>",
        short_desc = "Open file-exp by Ranger.",
        silent = true
    })

    -- vim.keymap.set({'n'}, '<leader>mm', ':Ranger<CR>')
end
return plugin
