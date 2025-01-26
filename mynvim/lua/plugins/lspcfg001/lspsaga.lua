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
    keymaps = {
        {
            mode = "n",
            key = "[n",
            action = "<cmd>Lspsaga diagnostic_jump_prev<CR>",
            desc = "Jump Prev Diagnostic"
        }, {
            mode = "n",
            key = "]n",
            action = "<cmd>Lspsaga diagnostic_jump_next<CR>",
            desc = "Jump Next Diagnostic"
        }, {
            mode = "n",
            key = "[m",
            action = "<cmd>lua lspsaga_diagno_gotoprev<cr>",
            desc = "Prev Jump With Filters"
        }, {
            mode = "n",
            key = "]m",
            action = "<cmd>lua lspsaga_diagno_gotonext<cr>",
            desc = "Next Jump With Filters"
        },

        {
            mode = {"n", "t"},
            key = "<A-t>",
            action = "<cmd>Lspsaga term_toggle<CR>",
            desc = "Floating terminal"
        },
        { tag = {key = "<leader>ls", name = "Lspsage"},

            keymaps = { -- LSP finder - Find the symbol's definition
                -- If there is no definition, it will instead be hidden
                -- When you use an action in finder like "open vsplit",
                -- you can use <C-t> to jump back
                {
                    mode = "n",
                    key = "<leader>lsf",
                    action = "<cmd>Lspsaga lsp_finder<CR>",
                    desc = "Find Symbol's Definition"
                }, {
                    mode = "n",
                    key = "<leader>lsa",
                    action = "<cmd>Lspsaga code_action<CR>",
                    desc = "Code Action"
                }, -- Rename all occurrences of the hovered word for the entire file
                {
                    mode = "n",
                    key = "<leader>lsr",
                    action = "<cmd>Lspsaga rename<CR>",
                    desc = "Rename Word"
                }, -- Rename all occurrences of the hovered word for the selected files
                {
                    mode = "n",
                    key = "<leader>lsR",
                    action = "<cmd>Lspsaga rename ++project<CR>",
                    desc = "Rename Word For Selected File"
                }, -- Peek definition
                -- You can edit the file containing the definition in the floating window
                -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
                -- It also supports tagstack
                -- Use <C-t> to jump back
                {
                    mode = "n",
                    key = "<leader>lsp",
                    action = "<cmd>Lspsaga peek_definition<CR>",
                    desc = "Peek Definition"
                }, -- Go to definition
                {
                    mode = "n",
                    key = "<leader>lsg",
                    action = "<cmd>Lspsaga goto_definition<CR>",
                    desc = "Goto Definition"
                }, -- Peek type definition
                -- You can edit the file containing the type definition in the floating window
                -- It also supports open/vsplit/etc operations, do refer to "definition_action_keys"
                -- It also supports tagstack
                -- Use <C-t> to jump back
                {
                    mode = "n",
                    key = "<leader>lsP",
                    action = "<cmd>Lspsaga peek_type_definition<CR>",
                    desc = "Peek Type Definition"
                }, -- Go to type definition
                {
                    mode = "n",
                    key = "<leader>lsG",
                    action = "<cmd>Lspsaga goto_type_definition<CR>",
                    desc = "Goto Type Definition"
                }, -- Show line diagnostics
                -- You can pass argument ++unfocus to
                -- unfocus the show_line_diagnostics floating window
                {
                    mode = "n",
                    key = "<leader>lsl",
                    action = "<cmd>Lspsaga show_line_diagnostics<CR>",
                    desc = "Show Line Diagnostics"
                }, -- Show buffer diagnostics
                {
                    mode = "n",
                    key = "<leader>lsb",
                    action = "<cmd>Lspsaga show_buf_diagnostics<CR>",
                    desc = "Show Buffer Diagnostics"
                }, -- Show workspace diagnostics
                {
                    mode = "n",
                    key = "<leader>lsw", 
                    action = "<cmd>Lspsaga show_workspace_diagnostics<CR>",
                    desc = "Show Workspace Diagnostics"
                }, -- Show cursor diagnostics
                {
                    mode = "n",
                    key = "<leader>lsc",
                    action = "<cmd>Lspsaga show_cursor_diagnostics<CR>",
                    desc = "Show Cursor Diagnostics"
                }, -- Diagnostic jump
                -- You can use <C-o> to jump back to your previous location
                -- Toggle outline
                {
                    mode = "n",
                    key = "<leader>lsO",
                    action = "<cmd>Lspsaga outline<CR>",
                    desc = "Lspsaga Outline(default)"
                }, -- Hover Doc
                -- If there is no hover doc,
                -- there will be a notification stating that
                -- there is no information available.
                -- To disable it just use ":Lspsaga hover_doc ++quiet"
                -- Pressing the key twice will enter the hover window
                {
                    mode = "n",
                    key = "<leader>lsh",
                    action = "<cmd>Lspsaga hover_doc<CR>",
                    desc = "Hover Doc"
                }, -- If you want to keep the hover window in the top right hand corner,
                -- you can pass the ++keep argument
                -- Note that if you use hover with ++keep, pressing this key again will
                -- lsose the hover window. If you want to jump to the hover window
                -- you should use the wincmd command "<C-w>w"
                {
                    mode = "n",
                    key = "<leader>lsH",
                    action = "<cmd>Lspsaga hover_doc ++keep<CR>",
                    desc = "Hover Doc & Keep Windown"
                }, -- Call hierarchy
                {
                    mode = "n",
                    key = "<leader>lsq",
                    action = "<cmd>Lspsaga incoming_calls<CR>",
                    desc = "Incoming Hierarchy Caslls"
                }, {
                    mode = "n",
                    key = "<leader>lsQ", 
                    action = "<cmd>Lspsaga outgoing_calls<CR>",
                    desc = "Outgoing Hierarchy Caslls"
                }
            }
        }
    }
}

return plugin
