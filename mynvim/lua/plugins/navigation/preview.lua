local plugin = {}

plugin.core = {
    'rmagatti/goto-preview',
    config = function()
        require('goto-preview').setup {}
    end

}

plugin.mapping = {
    tags = {{
        key = "<leader>np",
        desc = "+ Goto Preview"
    }},

    keys = {{
        mode = {"n"},
        key = {"<leader>", "n", "p", "d"},
        action = "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
        short_desc = "Preview definition"
    }, {
        mode = {"n"},
        key = {"<leader>", "n", "p", "t"},
        action = "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>",
        short_desc = "Preview type definition"
    }, {
        mode = {"n"},
        key = {"<leader>", "n", "p", "i"},
        action = "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>",
        short_desc = "Preview implementation"
    }, {
        mode = {"n"},
        key = {"<leader>", "n", "p", "c"},
        action = "<cmd>lua require('goto-preview').close_all_win()<CR>",
        short_desc = "Close all preview"
    }, {
        mode = {"n"},
        key = {"<leader>", "n", "p", "r"},
        action = "<cmd>lua require('goto-preview').references()<CR>",
        short_desc = "Preview references"
    }}
}

--[[
nnoremap gpd <cmd>lua require('goto-preview').goto_preview_definition()<CR>
nnoremap gpt <cmd>lua require('goto-preview').goto_preview_type_definition()<CR>
nnoremap gpi <cmd>lua require('goto-preview').goto_preview_implementation()<CR>
nnoremap gP <cmd>lua require('goto-preview').close_all_win()<CR>
nnoremap gpr <cmd>lua require('goto-preview').goto_preview_references()<CR>

vim.keymap.set("n", "gp", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", {noremap=true},


--]]
return plugin
