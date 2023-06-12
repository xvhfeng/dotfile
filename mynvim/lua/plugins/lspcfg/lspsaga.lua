local plugin = {}

plugin.core = {
    "glepnir/lspsaga.nvim",
    branch = "main",
    event = "LspAttach",
    config = function()
        require("lspsaga").setup({})
    end,
    dependencies = {{"nvim-tree/nvim-web-devicons"}, -- Please make sure you install markdown and markdown_inline parser
    {"nvim-treesitter/nvim-treesitter"}}

}

-- Diagnostic jump with filters such as only jumping to an error
function lspsaga_diagno_gotoprev()
    require("lspsaga.diagnostic"):goto_prev({
        severity = vim.diagnostic.severity.ERROR
    })
end

function lspsaga_diagno_gotonext()
    require("lspsaga.diagnostic"):goto_next({
        severity = vim.diagnostic.severity.ERROR
    })
end

plugin.mapping = {
    keys = { -- LSP finder - Find the symbol's definition
    -- If there is no definition, it will instead be hidden
    -- When you use an action in finder like "open vsplit",
    -- you can use <C-t> to jump back
    {
        mode = {"n"},
        key = {"<leader>", "l", "f"},
        action = "<cmd>Lspsaga lsp_finder<CR>",
        short_desc = "Find Symbol's Definition"
    }, {
        mode = {"n"},
        key = {"<leader>", "l", "a"},
        action = "<cmd>Lspsaga code_action<CR>",
        short_desc = "Code Action"
    }, -- Rename all occurrences of the hovered word for the entire file
    {
        mode = {"n"},
        key = {"<leader>", "l", "r"},
        action = "<cmd>Lspsaga rename<CR>",
        short_desc = "Rename Word"
    }, -- Rename all occurrences of the hovered word for the selected files
    {
        mode = {"n"},
        key = {"<leader>", "l", "R"},
        action = "<cmd>Lspsaga rename ++project<CR>",
        short_desc = "Rename Word For Selected File"
    }, -- Peek definition
    -- You can edit the file containing the definition in the floating window
    -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
    -- It also supports tagstack
    -- Use <C-t> to jump back
    {
        mode = {"n"},
        key = {"<leader>", "l", "p"},
        action = "<cmd>Lspsaga peek_definition<CR>",
        short_desc = "Peek Definition"
    }, -- Go to definition
    {
        mode = {"n"},
        key = {"<leader>", "l", "g"},
        action = "<cmd>Lspsaga goto_definition<CR>",
        short_desc = "Goto Definition"
    }, -- Peek type definition
    -- You can edit the file containing the type definition in the floating window
    -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
    -- It also supports tagstack
    -- Use <C-t> to jump back
    {
        mode = {"n"},
        key = {"<leader>", "l", "P"},
        action = "<cmd>Lspsaga peek_type_definition<CR>",
        short_desc = "Peek Type Definition"
    }, -- Go to type definition
    {
        mode = {"n"},
        key = {"<leader>", "l", "G"},
        action = "<cmd>Lspsaga goto_type_definition<CR>",
        short_desc = "Goto Type Definition"
    }, -- Show line diagnostics
    -- You can pass argument ++unfocus to
    -- unfocus the show_line_diagnostics floating window
    {
        mode = {"n"},
        key = {"<leader>", "l", "l"},
        action = "<cmd>Lspsaga show_line_diagnostics<CR>",
        short_desc = "Show Line Diagnostics"
    }, -- Show buffer diagnostics
    {
        mode = {"n"},
        key = {"<leader>", "l", "b"},
        action = "<cmd>Lspsaga show_buf_diagnostics<CR>",
        short_desc = "Show Buffer Diagnostics"
    }, -- Show workspace diagnostics
    {
        mode = {"n"},
        key = {"<leader>", "l", "w"},
        action = "<cmd>Lspsaga show_workspace_diagnostics<CR>",
        short_desc = "Show Workspace Diagnostics"
    }, -- Show cursor diagnostics
    {
        mode = {"n"},
        key = {"<leader>", "l", "c"},
        action = "<cmd>Lspsaga show_cursor_diagnostics<CR>",
        short_desc = "Show Cursor Diagnostics"
    }, -- Diagnostic jump
    -- You can use <C-o> to jump back to your previous location
    {
        mode = {"n"},
        key = {"[", "n"},
        action = "<cmd>Lspsaga diagnostic_jump_prev<CR>",
        short_desc = "Jump Prev Diagnostic"
    }, {
        mode = {"n"},
        key = {"]", "n"},
        action = "<cmd>Lspsaga diagnostic_jump_next<CR>",
        short_desc = "Jump Next Diagnostic"
    }, {
        mode = {"n"},
        key = {"[", "m"},
        action = ":lua lspsaga_diagno_gotoprev<cr>",
        expr = true,
        short_desc = "Prev Jump With Filters"
    }, {
        mode = {"n"},
        key = {"]", "m"},
        action = ":lua lspsaga_diagno_gotonext<cr>",
        expr = true,
        short_desc = "Next Jump With Filters"
    }, -- Toggle outline
    {
        mode = {"n"},
        key = {"<leader>", "l", "o"},
        action = "<cmd>Lspsaga outline<CR>",
        short_desc = "Outline"
    }, -- Hover Doc
    -- If there is no hover doc,
    -- there will be a notification stating that
    -- there is no information available.
    -- To disable it just use ":Lspsaga hover_doc ++quiet"
    -- Pressing the key twice will enter the hover window
    {
        mode = {"n"},
        key = {"<leader>", "l", "h"},
        action = "<cmd>Lspsaga hover_doc<CR>",
        short_desc = "Hover Doc"
    }, -- If you want to keep the hover window in the top right hand corner,
    -- you can pass the ++keep argument
    -- Note that if you use hover with ++keep, pressing this key again will
    -- close the hover window. If you want to jump to the hover window
    -- you should use the wincmd command "<C-w>w"
    {
        mode = {"n"},
        key = {"<leader>", "l", "H"},
        action = "<cmd>Lspsaga hover_doc ++keep<CR>",
        short_desc = "Hover Doc & Keep Windown"
    }, -- Call hierarchy
    {
        mode = {"n"},
        key = {"<leader>", "l", "q"},
        action = "<cmd>Lspsaga incoming_calls<CR>",
        short_desc = "Incoming Hierarchy Caslls"
    }, {
        mode = {"n"},
        key = {"<leader>", "l", "Q"},
        action = "<cmd>Lspsaga outgoing_calls<CR>",
        short_desc = "Outgoing Hierarchy Caslls"
    }, -- Floating terminal
    {
        mode = {"n", "t"},
        key = {"<A-t>"},
        action = "<cmd>Lspsaga term_toggle<CR>",
        short_desc = "Floating terminal"
    }}
}

return plugin
