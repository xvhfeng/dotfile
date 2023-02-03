local plugin = {}

plugin.core = {
    'rmagatti/goto-preview',
    config = function()
        require('goto-preview').setup {}
    end

}


plugin.mapping = function()
    local keymap = require('core.keymapping')
    keymap.add_mapping_prefix("<leader>np", {
        name = "+ Goto Preview"
    })
    keymap.register({
        mode = {"n"},
        key = {"<leader>", "n","p","d" },
        action = "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
        short_desc = "Preview definition",
    })

    keymap.register({
        mode = {"n"},
        key = {"<leader>", "n","p","t" },
        action = "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        short_desc = "Preview type definition",
    })

    keymap.register({
        mode = {"n"},
        key = {"<leader>", "n","p","i" },
        action = "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
        short_desc = "Preview implementation",
    })
    keymap.register({
        mode = {"n"},
        key = {"<leader>", "n","p","c" },
        action = "<cmd>lua require('goto-preview').close_all_win()<CR>",
        short_desc = "Close all preview",
    })
    keymap.register({
        mode = {"n"},
        key = {"<leader>", "n","p","r" },
        action = "<cmd>lua require('goto-preview').references()<CR>",
        short_desc = "Preview references",
    })
end
--[[
nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
nnoremap gpt <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>
nnoremap gpr <cmd>lua require('goto-preview').goto_preview_references()<CR>

vim.keymap.set("n", "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", {noremap=true})


--]]
return plugin
