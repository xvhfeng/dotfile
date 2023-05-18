local plugin = {}

plugin.core = {
    'ojroques/nvim-lspfuzzy',
    requires = {
        {'junegunn/fzf'},
        {'junegunn/fzf.vim'},  -- to enable preview (optional)
    },

    config = function()
        require('lspfuzzy').setup {}
    end,

}
plugin.mapping = function()
    local keymap = require('core.keymapping')
    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","m" },
        action = ":lua vim.lsp.buf.document_symbol()<cr>",
        expr = true,
        short_desc = "Function Document",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","r" },
        action = ":lua vim.lsp.buf.references()<cr>",
        expr = true,
        short_desc = "Function References",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","d" },
        action = ":lua vim.lsp.buf.definition()<cr>",
        expr = true,
        short_desc = "Function Definition",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","c" },
        action = ":lua vim.lsp.buf.code_action()<cr>",
        expr = true,
        short_desc = "Code Action",
    })

    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","p" },
        action = ":lua vim.lsp.diagnostic.goto_prev()<cr>",
        expr = true,
        short_desc = "Diagnostic Prev",
    })


    keymap.register({
        mode = {"n"},
        key = {"<leader>","l","n" },
        action = ":lua vim.lsp.diagnostic.goto_next()<cr>",
        expr = true,
        short_desc = "Diagnostic Next",
    })

end

return plugin
